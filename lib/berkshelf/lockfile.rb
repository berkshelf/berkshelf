module Berkshelf
  # The object representation of the Berkshelf lockfile. The lockfile is useful
  # when working in teams where the same cookbook versions are desired across
  # multiple workstations.
  class Lockfile
    require_relative 'cookbook_source'

    # @return [Pathname]
    #   the path to this Lockfile
    attr_reader :filepath

    # @return [Berkshelf::Berksfile]
    #   the Berksfile for this Lockfile
    attr_reader :berksfile

    # Create a new lockfile instance associated with the given Berksfile. If a
    # Lockfile exists, it is automatically loaded. Otherwise, an empty instance is
    # created and ready for use.
    #
    # @param berksfile [Berkshelf::Berksfile]
    #   the Berksfile associated with this Lockfile
    def initialize(berksfile)
      @berksfile = berksfile
      @filepath  = File.expand_path("#{berksfile.filepath}.lock")
      @sources   = {}

      load! if File.exists?(@filepath)
    end

    # Load the lockfile from file system.
    def load!
      contents = File.read(filepath).strip
      hash = parse(contents)

      hash[:sources].each do |name, options|
        # Dynamically calculate paths relative to the Berksfile if a path is given
        options[:path] &&= File.expand_path(options[:path], File.dirname(filepath))

        begin
          add(CookbookSource.new(berksfile, name.to_s, options))
        rescue Berkshelf::CookbookNotFound
          # It's possible that a source is locked that contains a path location, and
          # that path location was renamed or no longer exists. When loading the
          # lockfile, Berkshelf will throw an error if it can't find a cookbook that
          # previously existed at a path location.
        end
      end
    end

    # The list of sources constrained in this lockfile.
    #
    # @return [Array<Berkshelf::CookbookSource>]
    #   the list of sources in this lockfile
    def sources
      @sources.values
    end

    # Find the given source in this lockfile. This method accepts a source
    # attribute which may either be the name of a cookbook (String) or an
    # actual cookbook source.
    #
    # @param [String, Berkshelf::CookbookSource] source
    #   the cookbook source/name to find
    # @return [CookbookSource, nil]
    #   the cookbook source from this lockfile or nil if one was not found
    def find(source)
      @sources[cookbook_name(source).to_s]
    end

    # Determine if this lockfile contains the given source.
    #
    # @param [String, Berkshelf::CookbookSource] source
    #   the cookbook source/name to determine existence of
    # @return [Boolean]
    #   true if the source exists, false otherwise
    def has_source?(source)
      !find(source).nil?
    end

    # Replace the current list of sources with `sources`. This method does
    # not write out the lockfile - it only changes the state of the object.
    #
    # @param [Array<Berkshelf::CookbookSource>] sources
    #   the list of sources to update
    # @option options [String] :sha
    #   the sha of the Berksfile updating the sources
    def update(sources)
      reset_sources!
      sources.each { |source| append(source) }
      save
    end

    # Add the given source to the `sources` list, if it doesn't already exist.
    #
    # @param [Berkshelf::CookbookSource] source
    #   the source to append to the sources list
    def add(source)
      @sources[cookbook_name(source)] = source
    end
    alias_method :append, :add

    # Remove the given source from this lockfile. This method accepts a source
    # attribute which may either be the name of a cookbook (String) or an
    # actual cookbook source.
    #
    # @param [String, Berkshelf::CookbookSource] source
    #   the cookbook source/name to remove
    #
    # @raise [Berkshelf::CookbookNotFound]
    #   if the provided source does not exist
    def remove(source)
      unless has_source?(source)
        raise Berkshelf::CookbookNotFound, "'#{cookbook_name(source)}' does not exist in this lockfile!"
      end

      @sources.delete(cookbook_name(source))
    end
    alias_method :unlock, :remove

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
    #   * :sources [Array<Berkshelf::CookbookSource>] the list of sources
    def to_hash
      {
        sources: @sources
      }
    end

    # The JSON representation of this lockfile
    #
    # Relies on {#to_hash} to generate the json
    #
    # @return [String]
    #   the JSON representation of this lockfile
    def to_json(options = {})
      JSON.pretty_generate(to_hash, options)
    end

    private

      # Parse the given string as JSON.
      #
      # @param [String] contents
      #
      # @return [Hash]
      def parse(contents)
        # Ruby's JSON.parse cannot handle an empty string/file
        return { sha: nil, sources: [] } if contents.strip.empty?

        JSON.parse(contents, symbolize_names: true)
      rescue Exception => e
        if e.class == JSON::ParserError && contents =~ /^cookbook ["'](.+)["']/
          Berkshelf.ui.warn 'You are using the old lockfile format. Attempting to convert...'
          return LockfileLegacy.parse(berksfile, contents)
        else
          raise Berkshelf::LockfileParserError.new(filepath, e)
        end
      end

      # Save the contents of the lockfile to disk.
      def save
        File.open(filepath, 'w') do |file|
          file.write to_json + "\n"
        end
      end

      # Clear the sources array
      def reset_sources!
        @sources = {}
      end

      # Return the name of this cookbook (because it's the key in our
      # table).
      #
      # @param [Berkshelf::CookbookSource, #to_s] source
      #   the source to find the name from
      #
      # @return [String]
      #   the name of the cookbook
      def cookbook_name(source)
        source.is_a?(CookbookSource) ? source.name : source.to_s
      end

      # Legacy support for old lockfiles
      #
      # @todo Remove this class in Berkshelf 3.0.0
      class LockfileLegacy
        require 'pathname'

        class << self
          # Read the old lockfile content and instance eval in context.
          #
          # @param [Berkshelf::Berksfile] berksfile
          #   the associated berksfile
          # @param [String] content
          #   the string content read from a legacy lockfile
          def parse(berksfile, content)
            sources = {}.tap do |hash|
              content.split("\n").each do |line|
                next if line.empty?

                source = self.new(berksfile, line)
                hash[source.name] = source.options
              end
            end

            {
              sources: sources,
            }
          end
        end

        # @return [Hash]
        #   the hash of options
        attr_reader :options

        # @return [String]
        #   the name of this cookbook
        attr_reader :name

        # @return [Berkshelf::Berksfile]
        #   the berksfile
        attr_reader :berksfile

        # Create a new legacy lockfile for processing
        #
        # @param [String] content
        #   the content to parse out and convert to a hash
        def initialize(berksfile, content)
          @berksfile = berksfile
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
          @options = manipulate(options)
        end

        private
          # Perform various manipulations on the hash.
          #
          # @param [Hash] options
          def manipulate(options = {})
            if options[:path]
              options[:path] = berksfile.find(name).instance_variable_get(:@options)[:path] || options[:path]
            end
            options
          end
      end
  end
end
