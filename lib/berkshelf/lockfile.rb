require_relative 'dependency'

module Berkshelf
  # The object representation of the Berkshelf lockfile. The lockfile is useful
  # when working in teams where the same cookbook versions are desired across
  # multiple workstations.
  class Lockfile
    class << self
      # Initialize a Lockfile from the given filepath
      #
      # @param [String] filepath
      #   filepath to the lockfile
      def from_file(filepath)
        new(filepath: filepath)
      end

      # Initialize a Lockfile from the given Berksfile
      #
      # @param [Berkshelf::Berksfile] berksfile
      #   the Berksfile associated with the Lockfile
      def from_berksfile(berksfile)
        filepath = File.join(File.dirname(File.expand_path(berksfile.filepath)), Lockfile::DEFAULT_FILENAME)
        new(berksfile: berksfile, filepath: filepath)
      end
    end

    DEFAULT_FILENAME = 'Berksfile.lock'

    DEPENDENCIES = 'DEPENDENCIES'
    GRAPH        = 'GRAPH'

    NAME_VERSION         = '(?! )(.*?)(?: \(([^-]*)(?:-(.*))?\))?'
    DEPENDENCY_PATTERN   = /^ {2}#{NAME_VERSION}$/
    DEPENDENCIES_PATTERN = /^ {4}#{NAME_VERSION}$/
    OPTION_PATTERN       = /^ {4}(.+)\: (.+)/


    include Berkshelf::Mixin::Logging

    # @return [Pathname]
    #   the path to this Lockfile
    attr_reader :filepath

    # @return [Berkshelf::Berksfile]
    #   the Berksfile for this Lockfile
    attr_reader :berksfile

    # @return [Hash]
    #   the dependency graph
    attr_reader :graph

    # Create a new lockfile instance associated with the given Berksfile. If a
    # Lockfile exists, it is automatically loaded. Otherwise, an empty instance is
    # created and ready for use.
    #
    # @option options [String] :filepath
    #   filepath to the lockfile
    # @option options [Berkshelf::Berksfile] :berksfile
    #   the Berksfile associated with this Lockfile
    def initialize(options = {})
      @filepath     = options[:filepath].to_s
      @berksfile    = options[:berksfile]
      @dependencies = {}

      parse if File.exists?(@filepath)
    end

    #
    #
    def parse
      @parsed_dependencies = {}
      @parsed_graph = {}

      File.read(filepath).split(/(?:\r?\n)+/).each do |line|
        if line == DEPENDENCIES
          @state = :dependency
        elsif line == GRAPH
          @state = :graph
        else
          send("parse_#{@state}", line)
        end
      end

      @parsed_dependencies.each do |name, options|
        @dependencies[name] = Dependency.new(berksfile, name, options)
      end
    end

    # Determine if this lockfile actually exists on disk.
    #
    # @return [Boolean]
    #   true if this lockfile exists on the disk, false otherwise
    def present?
      File.exists?(filepath) && !File.read(filepath).strip.empty?
    end

    # Determine if we can "trust" this lockfile. A lockfile is trustworthy if:
    #
    #   1. All dependencies defined in the Berksfile are present in this
    #      lockfile
    #   2. Each dependency's constraint in the Berksfile is still satisifed by
    #      the currently locked version
    #
    # This method does _not_ account for leaky dependencies (i.e. dependencies
    # defined in the lockfile that are no longer present in the Berksfile); this
    # edge case is handed by the installer.
    #
    # @return [Boolean]
    #   true if this lockfile is trusted, false otherwise
    #
    def trusted?
      berksfile.dependencies.all? do |dependency|
        locked     = find(dependency)
        graphed    = graph.find(dependency)
        constraint = dependency.version_constraint

        locked && graphed && constraint.satisfies?(graphed.version)
      end
    end

    # Resolve this Berksfile and apply the locks found in the generated Berksfile.lock to the
    # target Chef environment
    #
    # @param [String] environment_name
    #
    # @option options [Hash] :ssl_verify (true)
    #   Disable/Enable SSL verification during uploads
    #
    # @raise [EnvironmentNotFound]
    #   if the target environment was not found
    # @raise [ChefConnectionError]
    #   if you are locking cookbooks with an invalid or not-specified client configuration
    def apply(environment_name, options = {})
      Berkshelf.ridley_connection(options) do |conn|
        unless environment = conn.environment.find(environment_name)
          raise EnvironmentNotFound.new(environment_name)
        end

        environment.cookbook_versions = {}.tap do |cookbook_versions|
          dependencies.each do |dependency|
            if dependency.locked_version.nil?
              # A locked version must be present for each entry. Older versions of the lockfile
              # may have contained dependencies with a special type of location that would attempt
              # to dynamically determine the locked version. This is incorrect and the Lockfile
              # should be regenerated if that is the case.
              raise InvalidLockFile, "Your lockfile contains a dependency without a locked version. This " +
                "may be because you have an old lockfile. Regenerate your lockfile and try again."
            end

            cookbook_versions[dependency.name] = "= #{dependency.locked_version.to_s}"
          end
        end

        environment.save
      end
    end

    # The list of dependencies constrained in this lockfile.
    #
    # @return [Array<Berkshelf::Dependency>]
    #   the list of dependencies in this lockfile
    def dependencies
      @dependencies.values
    end

    # Find the given dependency in this lockfile. This method accepts a dependency
    # attribute which may either be the name of a cookbook (String) or an
    # actual cookbook dependency.
    #
    # @param [String, Berkshelf::Dependency] dependency
    #   the cookbook dependency/name to find
    #
    # @return [Berkshelf::Dependency, nil]
    #   the cookbook dependency from this lockfile or nil if one was not found
    def find(dependency)
      @dependencies[cookbook_name(dependency).to_s]
    # Determine if this lockfile contains the given dependency.
    #
    # @param [String, Berkshelf::Dependency] dependency
    #   the cookbook dependency/name to determine existence of
    #
    # @return [Boolean]
    #   true if the dependency exists, false otherwise
    def dependency?(dependency)
      !find(dependency).nil?
    end

    end

    # Retrieve information about a given cookbook that is in this lockfile.
    #
    # @raise [DependencyNotFound]
    #   if this lockfile does not have the given dependency
    # @raise [CookbookNotFound]
    #   if this lockfile has the dependency, but the cookbook is not downloaded
    #
    # @param [String, Dependency] dependency
    #   the dependency or name of the dependency to find
    #
    # @return [CachedCookbook]
    #   the CachedCookbook that corresponds to the given name parameter
    def retrieve(dependency)
      locked = find(dependency)

      unless locked
        raise DependencyNotFound.new(cookbook_name(dependency))
      end

      unless locked.downloaded?
        raise CookbookNotFound, "Could not find cookbook '#{locked.to_s}'. " \
          "Run `berks install` to download and install the missing cookbook."
      end

      locked.cached_cookbook
    end

    # Replace the current dependency graph.
    #
    # @param [Array<CachedCookbook>] cookbooks
    #   the list of cookbooks to update the graph with
    def update_graph(cookbooks)
      @graph = cookbooks.sort.inject({}) do |hash, cookbook|
        hash[cookbook.cookbook_name] ||= {}
        hash[cookbook.cookbook_name][:version] = cookbook.version

        cookbook.dependencies.each do |name, constraint|
          hash[cookbook.cookbook_name][:dependencies] ||= {}
          hash[cookbook.cookbook_name][:dependencies][name] = constraint
        end

        hash
      end
    end

    # Replace the list of dependencies.
    #
    # @param [Array<Berkshelf::Dependency>] dependencies
    #   the list of dependencies to update
    def update_dependencies(dependencies)
      dependencies.each do |dependency|
        @dependencies[cookbook_name(dependency)] = dependency
      end
    end

    # Remove the given dependency from this lockfile. This method accepts a dependency
    # attribute which may either be the name of a cookbook (String) or an
    # actual cookbook dependency.
    #
    # @param [String, Berkshelf::Dependency] dependency
    #   the cookbook dependency/name to remove
    #
    # @raise [Berkshelf::CookbookNotFound]
    #   if the provided dependency does not exist
    def remove(dependency)
      unless dependency?(dependency)
        raise Berkshelf::CookbookNotFound, "'#{dependency}' does not exist in this lockfile!"
      end

      @dependencies.delete(cookbook_name(dependency))
    end
    alias_method :unlock, :remove

    # Write the contents of the current statue of the lockfile to disk. This
    # method uses an atomic file write. A temporary file is created, written,
    # and then copied over the existing one. This ensures any partial updates
    # or failures do no affect the lockfile. The temporary file is ensured
    # deletion.
    #
    # @return [String]
    #   the path where the lockfile was saved
    def save
      tempfile = Tempfile.new(['Berksfile',  '.lock'])

      unless dependencies.empty?
        tempfile.write(DEPENDENCIES)
        tempfile.write("\n")
        dependencies.sort.each do |dependency|
          tempfile.write(dependency.to_lock)
        end

        tempfile.write("\n")
        tempfile.write(GRAPH)
        tempfile.write("\n")

        graph.sort.each do |cookbook, info|
          tempfile.write("  #{cookbook} (#{info[:version]})\n")

          if info[:dependencies]
            info[:dependencies].each do |name, constraint|
              tempfile.write("    #{name} (#{constraint})\n")
            end
          end
        end
      end

      tempfile.rewind
      tempfile.close

      # Move the lockfile into place
      FileUtils.cp(tempfile.path, filepath)

      true
    ensure
      tempfile.unlink if tempfile
    end

    # @return [String]
    #   the string representation of the lockfile
    def to_s
      "#<Berkshelf::Lockfile #{Pathname.new(filepath).basename}>"
    end

    # @return [String]
    #   the detailed string representation of the lockfile
    def inspect
      "#<Berkshelf::Lockfile #{Pathname.new(filepath).basename}, dependencies: #{dependencies.inspect}>"
    end

    # Write the current lockfile to a hash
    #
    # @return [Hash]
    #   the hash representation of this lockfile
    #   * :dependencies [Array<Berkshelf::Dependency>] the list of dependencies
    def to_hash
      {
        dependencies: @dependencies
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

      def parse_dependency(line)
        if line =~ DEPENDENCY_PATTERN
          name, version = $1, $2

          @parsed_dependencies[name] ||= {}
          @parsed_dependencies[name][:constraint] = version if version
          @current_dependency = @parsed_dependencies[name]
        elsif line =~ OPTION_PATTERN
          key, value = $1, $2
          @current_dependency[key.to_sym] = value
        end
      end

      def parse_graph(line)
        if line =~ DEPENDENCY_PATTERN
          name, version = $1, $2

          @parsed_graph[name] ||= {}
          @parsed_graph[name][:version] = version
          @current_graph = @parsed_graph[name]
        elsif line =~ DEPENDENCIES_PATTERN
          name, constraint = $1, $2
          @current_graph[:dependencies] ||= {}
          @current_graph[:dependencies][name] = constraint
        end
      end

      def reset_dependencies!
        @dependencies = {}
      end

      # Return the name of this cookbook (because it's the key in our
      # table).
      #
      # @param [Berkshelf::Dependency, #to_s] dependency
      #   the dependency to find the name from
      #
      # @return [String]
      #   the name of the cookbook
      def cookbook_name(dependency)
        dependency.is_a?(Berkshelf::Dependency) ? dependency.name : dependency.to_s
      end

      # Legacy support for old lockfiles
      #
      # @todo Remove this class in Berkshelf 3.0.0
      class LockfileLegacy
        class << self
          # Read the old lockfile content and instance eval in context.
          #
          # @param [Berkshelf::Berksfile] berksfile
          #   the associated berksfile
          # @param [String] content
          #   the string content read from a legacy lockfile
          def parse(berksfile, content)
            dependencies = {}.tap do |hash|
              content.split("\n").each do |line|
                next if line.empty?
                source            = new(berksfile, line)
                hash[source.name] = source.options
              end
            end

            {
              dependencies: dependencies,
            }
          end

          # Warn the user they he/she is using an old Lockfile format.
          #
          # This automatically outputs to the {Berkshelf.ui}; nothing is
          # returned.
          #
          # @return [nil]
          def warn!
            Berkshelf.ui.warn(warning_message)
          end

          private
            # @return [String]
            def warning_message
              'You are using the old lockfile format. Attempting to convert...'
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

        # Method defined in legacy lockfiles (since we are using instance_eval).
        #
        # @param [String] name
        #   the name of this cookbook
        # @option options [String] :locked_version
        #   the locked version of this cookbook
        def cookbook(name, options = {})
          @name    = name
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
