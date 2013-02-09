module Berkshelf
  # The object representation of the Berkshelf lockfile. The lockfile is useful
  # when working in teams where the same cookbook versions are desired across
  # multiple workstations.
  #
  # @author Seth Vargo <sethvargo@gmail.com>
  class Lockfile
    class << self
      # Build a lockfile instance from the local .lock file.
      #
      # @raise [Errno::ENOENT]
      #   when the Lockfile cannot be found
      def from_file(filepath)
        begin
          contents = File.read(filepath)
        rescue Errno::ENOENT
          raise Berkshelf::LockfileNotFound, "Could not find lockfile at '#{filepath}'!"
        end

        json = MultiJson.load(contents)

        sources = json['sources'].collect { |s| Berkshelf::CookbookSource.from_json(s) }
        sha = json['sha']

        self.new(sources: sources, sha: sha)
      end
    end

    # The default filename for the lockfile (Berksfile.lock)
    DEFAULT_FILENAME = "#{Berkshelf::DEFAULT_FILENAME}.lock".freeze

    # @return [Array<Berkshelf::CookbookSource>]
    #   the list of sources in this lockfile
    attr_reader :sources

    # @return [String]
    #   the last known SHA of the Berksfile
    attr_accessor :sha

    # Create a new lockfile instance from the given sources and sha.
    #
    # @param [Hash] options
    #   a list of options to create the lockfile with
    # @option options [Array<Berkshelf::CookbookSource>]
    #   the list of cookbook sources
    # @option sha [String]
    #   the last-saved sha of the Berksfile
    def initialize(options = {})
      @sources = options[:sources]
      @sha = options[:sha]
    end

    # Save the contents of the lockfile to disk.
    def save
      File.open(DEFAULT_FILENAME, 'wb') do |file|
        file.write self.to_json + "\n"
      end
    end
    alias_method :write, :save

    # Replace the current list of sources with `sources`. This method does
    # not write out the lockfile - it only changes the state of the object.
    #
    # @param [Array<Berkshelf::CookbookSource>] sources
    #   the list of sources to update
    def update(sources)
      sources = [sources].flatten unless sources.is_a?(Array)

      unless sources.all? { |cookbook| cookbook.is_a?(Berkshelf::CookbookSource) }
        raise Berkshelf::ArgumentError, "`source` must be a Berkshelf::CookbookSource!"
      end

      @sources = sources
    end

    # Add the given source to the `sources` list, if it doesn't already exist.
    #
    # @param [Berkshelf::CookbookSource] source
    #   the source to append to the sources list
    def append(source)
      unless source.is_a?(Berkshelf::CookbookSource)
        raise Berkshelf::ArgumentError, "`source` must be a Berkshelf::CookbookSource!"
      end

      @sources.push(source) unless @sources.include?(source)
    end

    # Write the current lockfile to a hash
    #
    # @return [Hash]
    #   the hash representation of this lockfile
    #   * :sha [String] the last-known sha for the berksfile
    #   * :sources [Array<Berkshelf::CookbookSource>] the list of sources
    #   * :options [Hash] an arbitrary list of options for this lockfile
    def to_hash
      {
        sha: sha,
        sources: sources
      }
    end

    # The JSON representation of this lockfile
    #
    # Relies on {#to_hash} to generate the json
    #
    # @return [String]
    #   the JSON representation of this lockfile
    def to_json
      MultiJson.dump(self.to_hash, pretty: true)
    end
  end
end
