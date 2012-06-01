module KnifeCookbookDependencies
  class Resolver
    include DepSelector

    attr_reader :graph
    attr_reader :prime_package
    attr_reader :prime_version
    attr_reader :prime_metadata

    def initialize(source)
      @graph = DependencyGraph.new      
      @prime_package = add_package(source.name)
      @prime_version = add_version(prime_package, Version.new(source.metadata.version))
      @prime_metadata = source.metadata

      add_dependencies(prime_version, prime_metadata)
    end

    # @param [KCD::CookbookSource] source
    #   source to add
    def add_source(source)
      package = add_package(source.name)
      version = add_version(package, Version.new(source.metadata.version))
      add_dependencies(version, source.metadata)
    end

    def resolve_prime
      resolve_for(prime_package)
    end

    def resolve_for(package)
      quietly { selector.find_solution([SolutionConstraint.new(package)]) }
    end

    private

      def selector
        Selector.new(graph)
      end

      def add_package(name)
        graph.package(name)
      end

      # @param [String] name
      #   package name
      #
      # @param [DepSelector::Version] version
      #   version to add
      def add_version(package, version)
        package.add_version(version)
      end

      def add_dependency(version, dependency)
        version.dependencies << dependency
      end

      def add_dependencies(version, metadata)
        metadata.dependencies.each do |dep_name, constraint|
          add_dependency(version, Dependency.new(graph.package(dep_name), VersionConstraint.new(constraint)))
        end
      end
  end
end
