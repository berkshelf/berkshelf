module KnifeCookbookDependencies
  class Resolver
    include DepSelector

    attr_reader :graph

    def initialize(downloader, sources = Array.new)
      @downloader = downloader
      @graph = DependencyGraph.new
      @sources = Hash.new

      Array(sources).each do |source|
        add_source(source)
      end
    end

    # @param [KCD::CookbookSource] source
    #   source to add
    def add_source(source)
      downloader.download!(source) unless source.downloaded?

      package = add_package(source.name)
      version = add_version(package, Version.new(source.metadata.version))
      add_dependencies(version, source.dependencies)

      @sources[source.name] = source unless has_source?(source.name)

      source.dependency_sources.each { |source| add_source(source) }

      @sources
    end

    def sources
      @sources.collect { |name, source| source }
    end

    def resolve
      quietly { selector.find_solution(solution_constraints) }
    end

    # @param [String] name
    #   name of the source to return
    def [](name)
      @sources[name]
    end
    alias_method :get_source, :[]

    def has_source?(name)
      !get_source(name).nil?
    end

    private

      attr_reader :downloader

      def selector
        Selector.new(graph)
      end

      def solution_constraints
        constraints = sources.collect do |source|
          package = graph.package(source.name)
          SolutionConstraint.new(package)
        end
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

      def add_dependencies(version, dependencies)
        dependencies.each do |dep_name, constraint|
          add_dependency(version, Dependency.new(graph.package(dep_name), VersionConstraint.new(constraint)))
        end
      end
  end
end
