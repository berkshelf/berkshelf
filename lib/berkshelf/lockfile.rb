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
      # @param [String] filepath
      #   the path to the lockfile to load
      #
      # @raise [Errno::ENOENT]
      #   when the Lockfile cannot be found
      def from_file(filepath)
        begin
          contents = File.read(filepath)
        rescue Errno::ENOENT
          raise Berkshelf::LockfileNotFound, "Could not find lockfile at '#{filepath}'!"
        end

        begin
          hash = MultiJson.load(contents, symbolize_keys: true)
        rescue MultiJson::DecodeError
          if contents =~ /^cookbook ["'](.+)["']/
            Berkshelf.ui.warn "You are using the old lockfile format. Attempting to convert..."
            hash = LockfileLegacy.parse(contents)
          else
            raise
          end
        end

        lockfile = self.new(sha: hash[:sha], filepath: filepath)
        hash[:sources].each do |name, options|
          lockfile.add Berkshelf::CookbookSource.new(name, options)
        end
        lockfile
      end
    end

    # @return [Pathname]
    #   the path to this lockfile
    attr_reader :filepath

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
    # @option filepath [String]
    #   the path to this lockfile
    def initialize(options = {})
      @sha      = options[:sha]
      @filepath = options[:filepath]

      @sources = {}
    end

    # The list of sources constrained in this lockfile.
    #
    # @return [Array<Berkshelf::CookbookSource>]
    #   the list of sources in this lockfile
    def sources
      @sources.values
    end

    # Check if this lockfile has the given source
    #
    # @param [#to_s] source
    #   the source to check presence of
    #
    # @return [Boolean]
    #   true if the source exists, false otherwise
    def has_source?(source)
      @sources.has_key?(source.to_s)
    end

    # Save the contents of the lockfile to disk.
    def save
      File.open(filepath, 'w') do |file|
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
      @sources = {}
      sources.each { |source| append(source) }
    end

    # Add the given source to the `sources` list, if it doesn't already exist.
    #
    # @param [Berkshelf::CookbookSource] source
    #   the source to append to the sources list
    def add(source)
      @sources[source.name] = source
    end
    alias_method :append, :add

    # @return [String]
    #   the string representation of the lockfile
    def to_s
      "#<Berkshelf::Lockfile #{Pathname.new(filepath).basename}>"
    end

    # @return [String]
    #   the detailed string representation of the lockfile
    def inspect
      "#<Berkshelf::Lockfile #{Pathname.new(filepath).basename}, sources: #{sources.inspect}>"
    end

    # Write the current lockfile to a hash
    #
    # @return [Hash]
    #   the hash representation of this lockfile
    #   * :sha [String] the last-known sha for the berksfile
    #   * :sources [Array<Berkshelf::CookbookSource>] the list of sources
    def to_hash
      {
        sha: sha,
        sources: @sources
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

  private

    # Legacy support for old lockfiles
    #
    # @author Seth Vargo <sethvargo@gmail.com>
    # @todo Remove this class in the next major release.
    class LockfileLegacy
      class << self
        # Read the old lockfile content and instance eval in context.
        #
        # @param [String] content
        #   the string content read from a legacy lockfile
        def parse(content)
          sources = {}.tap do |hash|
            content.split("\n").each do |line|
              next if line.empty?

              source = self.new(line)
              hash[source.name] = source.options
            end
          end

          {
            sha: nil,
            sources: sources
          }
        end
      end

      # @return [Hash]
      #   the hash of options
      attr_reader :options

      # @return [String]
      #   the name of this cookbook
      attr_reader :name

      # Create a new legacy lockfile for processing
      #
      # @param [String] content
      #   the content to parse out and convert to a hash
      def initialize(content)
        instance_eval(content).to_hash
      end

      # Method defined in legacy lockfiles (since we are using
      # instance_eval).
      #
      # @param [String] name
      #   the name of this cookbook
      # @option options [String] :locked_version
      #   the locked version of this cookbook
      def cookbook(name, options = {})
        @name = name
        @options = options
      end
    end
end
