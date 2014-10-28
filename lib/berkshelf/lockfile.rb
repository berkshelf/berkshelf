require_relative 'dependency'

module Berkshelf
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
        parent = File.expand_path(File.dirname(berksfile.filepath))
        lockfile_name = "#{File.basename(berksfile.filepath)}.lock"

        filepath = File.join(parent, lockfile_name)
        new(berksfile: berksfile, filepath: filepath)
      end
    end

    DEFAULT_FILENAME = 'Berksfile.lock'.freeze

    DEPENDENCIES = 'DEPENDENCIES'.freeze
    GRAPH        = 'GRAPH'.freeze

    include Berkshelf::Mixin::Logging

    # @return [Pathname]
    #   the path to this Lockfile
    attr_reader :filepath

    # @return [Berkshelf::Berksfile]
    #   the Berksfile for this Lockfile
    attr_reader :berksfile

    # @return [Lockfile::Graph]
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
      @graph        = Graph.new(self)

      parse if File.exists?(@filepath)
    end

    # Parse the lockfile.
    #
    # @return true
    def parse
      LockfileParser.new(self).run
      true
    rescue => e
      raise LockfileParserError.new(e)
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
    #   2. Each dependency's transitive dependencies are contained and locked
    #      in the lockfile
    #   3. Each dependency's constraint in the Berksfile is still satisifed by
    #      the currently locked version
    #
    # This method does _not_ account for leaky dependencies (i.e. dependencies
    # defined in the lockfile that are no longer present in the Berksfile); this
    # edge case is handed by the installer.
    #
    # @return [Boolean]
    #   true if this lockfile is trusted, false otherwise
    def trusted?
      Berkshelf.log.info 'Checking if lockfile is trusted'

      checked = {}

      berksfile.dependencies.each do |dependency|
        Berkshelf.log.debug "Checking #{dependency}"

        locked = find(dependency)
        if locked.nil?
          Berkshelf.log.debug "  Not in lockfile - cannot be trusted!"
          return false
        end

        graphed = graph.find(dependency)
        if graphed.nil?
          Berkshelf.log.debug "  Not in graph - cannot be trusted!"
          return false
        end

        if cookbook = dependency.cached_cookbook
          Berkshelf.log.debug "  Detected there is a cached cookbook"

          unless (cookbook.dependencies.keys - graphed.dependencies.keys).empty?
            Berkshelf.log.debug "  Cached cookbook has different dependencies - cannot be trusted!"
            return false
          end
        end

        unless dependency.location == locked.location
          Berkshelf.log.debug "  Different location - cannot be trusted!"
          Berkshelf.log.debug "    Dependency location: #{dependency.location.inspect}"
          Berkshelf.log.debug "    Locked location:     #{locked.location.inspect}"
          return false
        end

        unless dependency.version_constraint.satisfies?(graphed.version)
          Berkshelf.log.debug "  Version constraint is not satisified - cannot be trusted!"
          return false
        end

        unless satisfies_transitive?(graphed, checked)
          Berkshelf.log.debug "  Transitive dependencies not satisfies - cannot be trusted!"
          return false
        end
      end

      true
    end

    # Recursive helper method for checking if transitive dependencies (i.e.
    # those dependencies defined in the metadata) are satisfied. This method is
    # used in calculating the trustworthiness of a lockfile.
    #
    # @param [GraphItem] graph_item
    #   the graph item to check transitive dependencies for
    # @param [Hash] checked
    #   the list of already checked dependencies
    #
    # @return [Boolean]
    def satisfies_transitive?(graph_item, checked, level = 0)
      indent = ' '*(level + 2)

      Berkshelf.log.debug "#{indent}Checking transitive dependencies for #{graph_item}"

      if checked[graph_item.name]
        Berkshelf.log.debug "#{indent}  Already checked - skipping"
        return true
      end

      graph_item.dependencies.each do |name, constraint|
        Berkshelf.log.debug "#{indent}  Checking #{name} (#{constraint})"

        graphed = graph.find(name)
        if graphed.nil?
          Berkshelf.log.debug "#{indent}  Not graphed - cannot be satisifed"
          return false
        end

        unless Semverse::Constraint.new(constraint).satisfies?(graphed.version)
          Berkshelf.log.debug "#{indent}  Version constraint is not satisfied"
          return false
        end

        checked[name] = true

        unless satisfies_transitive?(graphed, checked, level + 2)
          Berkshelf.log.debug "#{indent}  Transitive are not satisifed"
          return false
        end
      end
    end

    # Resolve this Berksfile and apply the locks found in the generated
    # +Berksfile.lock+ to the target Chef environment
    #
    # @param [String] name
    #   the name of the environment to apply the locks to
    #
    # @option options [Hash] :ssl_verify (true)
    #   Disable/Enable SSL verification during uploads
    #
    # @raise [EnvironmentNotFound]
    #   if the target environment was not found on the remote Chef Server
    # @raise [ChefConnectionError]
    #   if you are locking cookbooks with an invalid or not-specified client
    #   configuration
    def apply(name, options = {})
      Berkshelf.ridley_connection(options) do |connection|
        environment = connection.environment.find(name)

        raise EnvironmentNotFound.new(name) if environment.nil?

        locks = graph.locks.inject({}) do |hash, (name, dependency)|
          hash[name] = "= #{dependency.locked_version.to_s}"
          hash
        end

        environment.cookbook_versions = locks
        environment.save
      end
    end

    # @return [Array<CachedCookbook>]
    def cached
      graph.locks.values.collect { |dependency| dependency.cached_cookbook }
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
      @dependencies[Dependency.name(dependency)]
    end

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
    alias_method :has_dependency?, :dependency?

    # Add a new cookbok to the lockfile. If an entry already exists by the
    # given name, it will be overwritten.
    #
    # @param [Dependency] dependency
    #   the dependency to add
    #
    # @return [Dependency]
    def add(dependency)
      @dependencies[Dependency.name(dependency)] = dependency
    end

    def locks
      graph.locks
    end

    # Retrieve information about a given cookbook that is in this lockfile.
    #
    # @raise [DependencyNotFound]
    #   if this lockfile does not have the given dependency
    # @raise [CookbookNotFound]
    #   if this lockfile has the dependency, but the cookbook is not installed
    #
    # @param [String, Dependency] dependency
    #   the dependency or name of the dependency to find
    #
    # @return [CachedCookbook]
    #   the CachedCookbook that corresponds to the given name parameter
    def retrieve(dependency)
      locked = graph.locks[Dependency.name(dependency)]

      if locked.nil?
        raise DependencyNotFound.new(Dependency.name(dependency))
      end

      unless locked.installed?
        name    = locked.name
        version = locked.locked_version || locked.version_constraint
        raise CookbookNotFound.new(name, version, 'in the cookbook store')
      end

      locked.cached_cookbook
    end

    # Replace the list of dependencies.
    #
    # @param [Array<Berkshelf::Dependency>] dependencies
    #   the list of dependencies to update
    def update(dependencies)
      @dependencies = {}

      dependencies.each do |dependency|
        @dependencies[Dependency.name(dependency)] = dependency
      end
    end

    # Remove the given dependency from this lockfile. This method accepts a
    # +dependency+ attribute which may either be the name of a cookbook, as a
    # String or an actual {Dependency} object.
    #
    # This method first removes the dependency from the list of top-level
    # dependencies. Then it uses a recursive algorithm to safely remove any
    # other dependencies from the graph that are no longer needed.
    #
    # @param [String] dependency
    #   the name of the cookbook to remove
    def unlock(dependency, force = false)
      @dependencies.delete(Dependency.name(dependency))

      if force
        graph.remove(dependency, ignore: graph.locks.keys)
      else
        graph.remove(dependency)
      end
    end

    # Completely remove all dependencies from the lockfile and underlying graph.
    def unlock_all
      @dependencies = {}
      @graph        = Graph.new(self)
    end

    # Iterate over each top-level dependency defined in the lockfile and
    # check if that dependency is still defined in the Berksfile.
    #
    # If the dependency is no longer present in the Berksfile, it is "safely"
    # removed using {Lockfile#unlock} and {Lockfile#remove}. This prevents
    # the lockfile from "leaking" dependencies when they have been removed
    # from the Berksfile, but still remained locked in the lockfile.
    #
    # If the dependency exists, a constraint comparison is conducted to verify
    # that the locked dependency still satisifes the original constraint. This
    # handles the edge case where a user has updated or removed a constraint
    # on a dependency that already existed in the lockfile.
    #
    # @raise [OutdatedDependency]
    #   if the constraint exists, but is no longer satisifed by the existing
    #   locked version
    #
    # @return [Array<Dependency>]
    def reduce!
      Berkshelf.log.info "Reducing lockfile"

      Berkshelf.log.debug "Current lockfile:"
      Berkshelf.log.debug ""
      to_lock.each_line do |line|
        Berkshelf.log.debug "  #{line.chomp}"
      end
      Berkshelf.log.debug ""


      # Unlock any locked dependencies that are no longer in the Berksfile
      Berkshelf.log.debug "Unlocking dependencies no longer in the Berksfile"

      dependencies.each do |dependency|
        Berkshelf.log.debug "  Checking #{dependency}"

        if berksfile.has_dependency?(dependency.name)
          Berkshelf.log.debug "    Skipping unlock for #{dependency.name} (exists in the Berksfile)"
        else
          Berkshelf.log.debug "    Unlocking #{dependency.name}"
          unlock(dependency, true)
        end
      end

      # Remove any transitive dependencies
      Berkshelf.log.debug "Removing transitive dependencies"

      berksfile.dependencies.each do |dependency|
        Berkshelf.log.debug "  Checking #{dependency}"

        graphed = graph.find(dependency)

        if graphed.nil?
          Berkshelf.log.debug "    Skipping (not graphed)"
          next
        end

        unless dependency.version_constraint.satisfies?(graphed.version)
          Berkshelf.log.debug "    Constraints are not satisfied!"
          raise OutdatedDependency.new(graphed, dependency)
        end

        if cookbook = dependency.cached_cookbook
          Berkshelf.log.debug "    Cached cookbook exists"
          Berkshelf.log.debug "    Checking dependencies on the cached cookbook"

          graphed.dependencies.each do |name, constraint|
            Berkshelf.log.debug "      Checking #{name} (#{constraint})"

            # Unless the cookbook still depends on this key, we want to queue it
            # for unlocking. This is the magic that prevents transitive
            # dependency leaking.
            unless cookbook.dependencies.has_key?(name)
              Berkshelf.log.debug "        Not found!"
              unlock(name, true)
            end
          end
        end
      end

      Berkshelf.log.debug "New lockfile:"
      Berkshelf.log.debug ""
      to_lock.each_line do |line|
        Berkshelf.log.debug "  #{line.chomp}"
      end
      Berkshelf.log.debug ""
    end


    # Write the contents of the current statue of the lockfile to disk. This
    # method uses an atomic file write. A temporary file is created, written,
    # and then copied over the existing one. This ensures any partial updates
    # or failures do no affect the lockfile. The temporary file is ensured
    # deletion.
    #
    # @return [true, false]
    #   true if the lockfile was saved, false otherwise
    def save
      return false if dependencies.empty?

      tempfile = Tempfile.new(['Berksfile',  '.lock'])

      tempfile.write(to_lock)

      tempfile.rewind
      tempfile.close

      # Move the lockfile into place
      FileUtils.cp(tempfile.path, filepath)

      true
    ensure
      tempfile.unlink if tempfile
    end

    # @private
    def to_lock
      out = "#{DEPENDENCIES}\n"
      dependencies.sort.each do |dependency|
        out << dependency.to_lock
      end
      out << "\n"
      out << graph.to_lock
      out
    end

    # @private
    def to_s
      "#<Berkshelf::Lockfile #{Pathname.new(filepath).basename}>"
    end

    # @private
    def inspect
      "#<Berkshelf::Lockfile #{Pathname.new(filepath).basename}, dependencies: #{dependencies.inspect}>"
    end

    private

      # The class responsible for parsing the lockfile and turning it into a
      # useful data structure.
      class LockfileParser
        NAME_VERSION         = '(?! )(.*?)(?: \(([^-]*)(?:-(.*))?\))?'.freeze
        DEPENDENCY_PATTERN   = /^ {2}#{NAME_VERSION}$/.freeze
        DEPENDENCIES_PATTERN = /^ {4}#{NAME_VERSION}$/.freeze
        OPTION_PATTERN       = /^ {4}(.+)\: (.+)/.freeze

        # Create a new lockfile parser.
        #
        # @param [Lockfile]
        def initialize(lockfile)
          @lockfile  = lockfile
          @berksfile = lockfile.berksfile
        end

        # Parse the lockfile contents, adding the correct things to the lockfile.
        #
        # @return [true]
        def run
          @parsed_dependencies = {}

          contents = File.read(@lockfile.filepath)

          if contents.strip.empty?
            Berkshelf.formatter.warn "Your lockfile at '#{@lockfile.filepath}' " \
              "is empty. I am going to parse it anyway, but there is a chance " \
              "that a larger problem is at play. If you manually edited your " \
              "lockfile, you may have corrupted it."
          end

          if contents.strip[0] == '{'
            Berkshelf.formatter.warn "It looks like you are using an older " \
              "version of the lockfile. Attempting to convert..."

            dependencies = "#{Lockfile::DEPENDENCIES}\n"
            graph        = "#{Lockfile::GRAPH}\n"

            begin
              hash = JSON.parse(contents)
            rescue JSON::ParserError
              Berkshelf.formatter.warn "Could not convert lockfile! This is a " \
              "problem. You see, previous versions of the lockfile were " \
              "actually a lie. It lied to you about your version locks, and we " \
              "are really sorry about that.\n\n" \
              "Here's the good news - we fixed it!\n\n" \
              "Here's the bad news - you probably should not trust your old " \
              "lockfile. You should manually delete your old lockfile and " \
              "re-run the installer."
            end

            hash['dependencies'] && hash['dependencies'].sort .each do |name, info|
              dependencies << "  #{name} (>= 0.0.0)\n"
              info.each do |key, value|
                unless key == 'locked_version'
                  dependencies << "    #{key}: #{value}\n"
                end
              end

              graph << "  #{name} (#{info['locked_version']})\n"
            end

            contents = "#{dependencies}\n#{graph}"
          end

          contents.split(/(?:\r?\n)+/).each do |line|
            if line == Lockfile::DEPENDENCIES
              @state = :dependency
            elsif line == Lockfile::GRAPH
              @state = :graph
            else
              send("parse_#{@state}", line)
            end
          end

          @parsed_dependencies.each do |name, options|
            dependency = Dependency.new(@berksfile, name, options)
            @lockfile.add(dependency)
          end

          true
        end

        private

          # Parse a dependency line.
          #
          # @param [String] line
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

          # Parse a graph line.
          #
          # @param [String] line
          def parse_graph(line)
            if line =~ DEPENDENCY_PATTERN
              name, version = $1, $2

              @lockfile.graph.find(name) || @lockfile.graph.add(name, version)
              @current_lock = name
            elsif line =~ DEPENDENCIES_PATTERN
              name, constraint = $1, $2
              @lockfile.graph.find(@current_lock).add_dependency(name, constraint)
            end
          end
      end

      # The class representing an internal graph.
      class Graph
        include Enumerable

        # Create a new Lockfile graph.
        #
        # Some clarifying terminology:
        #
        #     yum-epel (0.2.0) <- lock
        #       yum (~> 3.0)   <- dependency
        #
        # @return [Graph]
        def initialize(lockfile)
          @lockfile  = lockfile
          @berksfile = lockfile.berksfile
          @graph     = {}
        end

        # @yield [Hash<String]
        def each(&block)
          @graph.values.each(&block)
        end

        # The list of locks for this graph. Dependencies are retrieved from the
        # lockfile, then the Berksfile, and finally a new dependency object is
        # created if none of those exist.
        #
        # @return [Hash<String, Dependency>]
        #   a key-value hash where the key is the name of the cookbook and the
        #   value is the locked dependency
        def locks
          @graph.sort.inject({}) do |hash, (name, item)|
            dependency = @lockfile.find(name)  ||
                         @berksfile && @berksfile.find(name) ||
                         Dependency.new(@berksfile, name)

            # We need to make a copy of the dependency, or else we could be
            # modifying an existing object that other processes depend on!
            dependency = dependency.dup
            dependency.locked_version = item.version

            hash[item.name] = dependency
            hash
          end
        end

        # Find a given dependency in the graph.
        #
        # @param [Dependency, String]
        #   the name/dependency to find
        #
        # @return [GraphItem, nil]
        #   the item for the name
        def find(dependency)
          @graph[Dependency.name(dependency)]
        end

        # Find if the given lock exists?
        #
        # @param [Dependency, String]
        #   the name/dependency to find
        #
        # @return [true, false]
        def lock?(dependency)
          !find(dependency).nil?
        end
        alias_method :has_lock?, :lock?

        # Determine if this graph contains the given dependency. This method is
        # used by the lockfile when adding or removing dependencies to see if a
        # dependency can be safely removed.
        #
        # @param [Dependency, String] dependency
        #   the name/dependency to find
        #
        # @option options [String, Array<String>] :ignore
        #   the list of dependencies to ignore
        def dependency?(dependency, options = {})
          name   = Dependency.name(dependency)
          ignore = Hash[*Array(options[:ignore]).map { |i| [i, true] }.flatten]

          @graph.values.each do |item|
            next if ignore[item.name]

            if item.dependencies.key?(name)
              return true
            end
          end

          false
        end
        alias_method :has_dependency?, :dependency?

        # Add each a new {GraphItem} to the graph.
        #
        # @param [#to_s] name
        #   the name of the cookbook
        # @param [#to_s] version
        #   the version of the lock
        #
        # @return [GraphItem]
        def add(name, version)
          @graph[name.to_s] = GraphItem.new(name, version)
        end

        # Recursively remove any dependencies from the graph unless they exist as
        # top-level dependencies or nested dependencies.
        #
        # @param [Dependency, String] dependency
        #   the name/dependency to remove
        #
        # @option options [String, Array<String>] :ignore
        #   the list of dependencies to ignore
        def remove(dependency, options = {})
          name = Dependency.name(dependency)

          if @lockfile.dependency?(name)
            return
          end

          if dependency?(name, options)
            return
          end

          # Grab the nested dependencies for this particular entry so we can
          # recurse and try to remove them from the graph.
          locked = @graph[name]
          nested_dependencies = locked && locked.dependencies.keys || []

          # Now delete the entry
          @graph.delete(name)

          # Recursively try to delete the remaining dependencies for this item
          nested_dependencies.each(&method(:remove))
        end

        # Update the graph with the given cookbooks. This method destroys the
        # existing dependency graph with this new result!
        #
        # @param [Array<CachedCookbook>]
        #   the list of cookbooks to populate the graph with
        def update(cookbooks)
          @graph = {}

          cookbooks.each do |cookbook|
            @graph[cookbook.cookbook_name.to_s] = GraphItem.new(
              cookbook.cookbook_name,
              cookbook.version,
              cookbook.dependencies,
            )
          end
        end

        # Write the contents of the graph to the lockfile format.
        #
        # The resulting format looks like:
        #
        #     GRAPH
        #       apache2 (1.8.14)
        #       yum-epel (0.2.0)
        #         yum (~> 3.0)
        #
        # @example lockfile.graph.to_lock #=> "GRAPH\n  apache2 (1.18.14)\n..."
        #
        # @return [String]
        #
        def to_lock
          out = "#{Lockfile::GRAPH}\n"
          @graph.sort.each do |name, item|
            out << "  #{name} (#{item.version})\n"

            unless item.dependencies.empty?
              item.dependencies.sort.each do |name, constraint|
                out << "    #{name} (#{constraint})\n"
              end
            end
          end

          out
        end

        private

          # A single item inside the graph.
          class GraphItem
            # The name of the cookbook that corresponds to this graph item.
            #
            # @return [String]
            #   the name of the cookbook
            attr_reader :name

            # The locked version for this graph item.
            #
            # @return [String]
            #   the locked version of the graph item (as a string)
            attr_reader :version

            # The list of dependencies and their constraints.
            #
            # @return [Hash<String, String>]
            #   the list of dependencies for this graph item, where the key
            #   corresponds to the name of the dependency and the value is the
            #   version constraint.
            attr_reader :dependencies

            # Create a new graph item.
            def initialize(name, version, dependencies = {})
              @name         = name.to_s
              @version      = version.to_s
              @dependencies = dependencies
            end

            # Add a new dependency to the list.
            #
            # @param [#to_s] name
            #   the name to use
            # @param [#to_s] constraint
            #   the version constraint to use
            def add_dependency(name, constraint)
              @dependencies[name.to_s] = constraint.to_s
            end

            # @private
            def to_s
              "#{name} (#{version})"
            end
          end
      end
  end
end
