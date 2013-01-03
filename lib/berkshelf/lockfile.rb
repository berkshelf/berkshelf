module Berkshelf
  class Lockfile
    class << self
      # Build a lockfile instance from the local .lock file.
      #
      # @raises Errno::ENOENT
      #   when the Lockfile cannot be found
      def load(filename)
        begin
          contents = File.read(filename)
        rescue Errno::ENOENT
          raise ::Berkshelf::LockfileNotFound, "Could not find a valid lock file at #{filename}"
        end

        json = MultiJson.load(contents, symbolize_keys: true)
        sources = json[:sources].map{ |source| ::Berkshelf::CookbookSource.from_json(source) }
        lockfile = new(sources, json[:options])
        lockfile.instance_variable_set(:@sha, json[:sha])
        lockfile
      end
    end

    # @return [Array<Berkshelf::CookbookSource>]
    #   the list of sources for this lockfile
    attr_reader :sources

    # Create a new lockfile instance from the given sources.
    #
    # @param [Array<Berkshelf::CookbookSource>] sources
    #   the list of cookbook sources
    # @param [Hash] options
    #   a list of options to pass to the lockfile
    def initialize(sources, options = {})
      @options = options
      @sources = sources
    end

    def save
      File.open(lockfile_name, 'wb') do |file|
        file.write self.to_json
      end
    end
    alias_method :write, :save

    # Replace the current list of sources with `sources`. This method does
    # not write out the lockfile - it only changes the state of the object.
    #
    # @param [Array<Berkshelf::CookbookSource>]
    #   the list of sources to update
    def update(sources)
      unless sources.all?{ |cookbook| cookbook.is_a?(::Berkshelf::CookbookSource) }
        raise ::Berkshelf::ArgumentError, "`sources` must be a Berkshelf::CookbookSource!"
      end
      @sources = sources
    end

    # Add the given source to the `sources` list, if it doesn't already exist.
    #
    # @param [Berkshelf::CookbookSource]
    #   the source to append to the sources list
    def append(source)
      unless source.is_a?(::Berkshelf::CookbookSource)
        raise ::Berkshelf::ArgumentError, "`source` must be a Berkshelf::CookbookSource!"
      end

      @sources.push(source) unless @sources.include?(source)
    end

    # The last known sha of the the Berksfile from a successful install.
    #
    # This is used to quickly detect if the Berksfile has changed since the
    # last install.
    #
    # @return [String, nil]
    #   the last known SHA for the Berksfile
    def sha
      @sha ||= ::Berkshelf::Berksfile.from_file(options[:berksfile]).sha
    end

    # The lockfile name associated with this berksfile
    #
    # @return [String]
    #   the berksfile + '.lock'
    def lockfile_name
      options[:berksfile] + '.lock'
    end

    def to_hash
      {
        sha: sha,
        sources: sources,
        options: options
      }
    end

    def to_json
      MultiJson.dump(self.to_hash, pretty: true)
    end

    private
    def options
      @options ||= {}
    end
  end
end
