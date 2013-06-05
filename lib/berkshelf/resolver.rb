require_relative 'dependency'
require_relative 'locations/git_location'
require_relative 'locations/path_location'

module Berkshelf
  class Resolver
    extend Forwardable

    # @return [Berkshelf::Berksfile]
    attr_reader :berksfile

    # @return [Solve::Graph]
    attr_reader :graph

    # @param [Berkshelf::Berksfile] berksfile
    # @param [Hash] options
    #
    # @option options [Array<Berkshelf::Dependency>, Berkshelf::Dependency] dependencies
    def initialize(berksfile, options = {})
      @berksfile    = berksfile
      @downloader   = berksfile.downloader
      @graph        = Solve::Graph.new
      @dependencies = Hash.new

      # Dependencies need to be added AFTER the dependencies. If they are
      # not, then one of the dependencies of a dependency that is added
      # may take precedence over an explicitly set dependency that appears
      # later in the iterator.
      Array(options[:dependencies]).each do |dependency|
        add_dependency(dependency, false)
      end

      unless options[:skip_dependencies]
        Array(options[:dependencies]).each do |dependency|
          add_recursive_dependencies(dependency)
        end
      end
    end

    # Add the given dependency to the collection of dependencies for this instance
    # of Resolver. By default the dependencies of the given dependency will also
    # be added as dependencies to the collection.
    #
    # @param [Berkshelf::Dependency] dependency
    #   dependency to add
    # @param [Boolean] include_dependencies
    #   adds the dependencies of the given dependency as dependencies to the collection of
    #   if true. Dependencies will be ignored if false.
    #
    # @return [Array<Berkshelf::Dependency>]
    def add_dependency(dependency, include_dependencies = true)
      if has_dependency?(dependency)
        raise DuplicateDependencyDefined, "A dependency named '#{dependency.name}' is already present."
      end

      @dependencies[dependency.name] = dependency
      use_dependency(dependency) || install_dependency(dependency)

      graph.artifacts(dependency.name, dependency.cached_cookbook.version)

      if include_dependencies
        add_recursive_dependencies(dependency)
      end

      dependencies
    end

    # Add the dependencies of the given dependency as dependencies in the collection of dependencies
    # on this instance of Resolver. Any dependencies which already have a dependency in the
    # collection of dependencies of the same name will not be added to the collection a second
    # time.
    #
    # @param [Berkshelf::Dependency] dependency
    #   dependency to convert dependencies into dependencies
    #
    # @return [Array<Berkshelf::Dependency>]
    def add_recursive_dependencies(dependency)
      dependency.cached_cookbook.dependencies.each do |name, constraint|
        next if has_dependency?(name)

        add_dependency(Berkshelf::Dependency.new(berksfile, name, constraint: constraint))
      end
    end

    # @return [Array<Berkshelf::Dependency>]
    #   an array of Berkshelf::Dependencys that are currently added to this resolver
    def dependencies
      @dependencies.values
    end

    # Finds a solution for the currently added dependencies and their dependencies and
    # returns an array of CachedCookbooks.
    #
    # @return [Array<Berkshelf::CachedCookbook>]
    def resolve
      demands = [].tap do |l_demands|
        graph.artifacts.each do |artifact|
          l_demands << [ artifact.name, artifact.version ]
        end
      end

      solution = Solve.it!(graph, demands)

      [].tap do |cached_cookbooks|
        solution.each do |name, version|
          cached_cookbooks << get_dependency(name).cached_cookbook
        end
      end
    end

    # @param [Berkshelf::Dependency, #to_s] dependency
    #   name of the dependency to return
    #
    # @return [Berkshelf::Dependency]
    def [](dependency)
      if dependency.is_a?(Berkshelf::Dependency)
        dependency = dependency.name
      end
      @dependencies[dependency.to_s]
    end
    alias_method :get_dependency, :[]

    # @param [CoobookSource, #to_s] dependency
    #   the dependency to test if the resolver has added
    def has_dependency?(dependency)
      !get_dependency(dependency).nil?
    end

    # The string representation of the Resolver.
    #
    # @return [String]
    def to_s
      "#<#{self.class} berksfile: #{berksfile.filepath}>"
    end

    # The detailed string representation of the Resolver.
    #
    # @return [String]
    def inspect
      "#<#{self.class} " +
        "berksfile: #{berksfile.filepath}, " +
        "sources: [#{dependencies.map(&:name_and_version).join(', ')}]" +
      ">"
    end

    private

      attr_reader :downloader

      # @param [Berkshelf::Dependency] dependency
      #
      # @return [Boolean]
      def install_dependency(dependency)
        cached_cookbook, location = downloader.download(dependency)
        Berkshelf.formatter.install(dependency.name, cached_cookbook.version, location)
      end

      # Use the given dependency to create a constraint solution if the dependency has been downloaded or can
      # be satisfied by a cached cookbook that is already present in the cookbook store.
      #
      # @note Git location dependencies which have not yet been downloaded will not be satisfied by a
      #   cached cookbook from the cookbook store.
      #
      # @param [Berkshelf::Dependency] dependency
      #
      # @raise [ConstraintNotSatisfied] if the CachedCookbook does not satisfy the version constraint of
      #   this instance of Location.
      #   contain a cookbook that satisfies the given version constraint of this instance of
      #   Berkshelf::Dependency.
      #
      # @return [Boolean]
      def use_dependency(dependency)
        name       = dependency.name
        constraint = dependency.version_constraint
        location   = dependency.location

        if dependency.downloaded?
          cached = dependency.cached_cookbook
          location.validate_cached(cached)
          Berkshelf.formatter.use(name, cached.version, location)
          true
        elsif location.is_a?(GitLocation)
          false
        else
          cached = downloader.cookbook_store.satisfy(name, constraint)

          if cached
            get_dependency(dependency).cached_cookbook = cached
            Berkshelf.formatter.use(name, cached.version)
            true
          else
            false
          end
        end
      end
  end
end
