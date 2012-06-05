module KnifeCookbookDependencies
  class Resolver
    extend Forwardable
    include DepSelector

    def_delegators :@graph, :package, :packages

    def initialize(downloader, sources = Array.new)
      @downloader = downloader
      @graph = DependencyGraph.new
      @sources = Hash.new

      Array(sources).each do |source|
        add_source(source, false)
      end

      self.sources.each do |source|
        package_version = package(source.name)[Version.new(source.metadata.version)]
        add_dependencies(package_version, source.dependencies)
      end
    end

    # @param [KCD::CookbookSource] source
    #   source to add
    # @param [Boolean] include_dependencies
    #   if true, after adding the source the dependencies defined in the
    #   sources metadata will be added to the graph and downloaded
    #
    # @returns [DepSelector::PackageVersion]
    def add_source(source, include_dependencies = true)
      raise DuplicateSourceDefined if has_source?(source.name)

      set_source(source.name, source)

      if downloader.downloaded?(source)
        KCD.ui.info "Using #{source.name} #{source.metadata.version}"
      else
        KCD.ui.info "Downloading #{source.name} #{source.version_constraint} from #{source.location}"
        downloader.download!(source)
      end

      package = add_package(source.name)
      package_version = add_version(package, Version.new(source.metadata.version))
      
      add_dependencies(package_version, source.dependencies) if include_dependencies

      package_version
    end

    # @param [DepSelector::PackageVersion] parent_pkgver
    #   the PackageVersion you would like to add the given dependencies to. In this case
    #   the package version is a version of a Cookbook.
    # @param [Hash] dependencies
    #   A hash containing Cookbook names for keys and version constraint strings for
    #   values. This is the same format obtained by sending the 'dependencies' message
    #   to an instance of Chef::Cookbook::Metadata.
    #
    #   Example:
    #       { 
    #         "build-essential" => ">= 0.0.0",
    #         "ohai" => "~> 1.0.2"
    #       }
    def add_dependencies(parent_pkgver, dependencies)
      dependencies.each do |name, constraint|
        dep_package = add_package(name)
        parent_pkgver.dependencies << Dependency.new(dep_package, VersionConstraint.new(constraint))

        unless has_source?(name)
          source = CookbookSource.new(name, constraint)

          if downloader.downloaded?(source)
            KCD.ui.info "Using #{source.name} #{source.metadata.version}"
          else
            KCD.ui.info "Downloading #{source.name} #{source.version_constraint} from #{source.location}"
            downloader.download!(source)
          end

          dep_pkgver = add_version(dep_package, Version.new(source.metadata.version))
          add_dependencies(dep_pkgver, source.dependencies)
        end
      end
    end

    # @return [Array<KCD::CookbookSource>]
    #   an array of CookbookSources that are currently added to this resolver
    def sources
      @sources.collect { |name, source| source }
    end

    # @return [Hash]
    #   a hash containing package names - in this case Cookbook names - as keys and
    #   their locked version as values.
    #
    #   Example:
    #       { 
    #         "nginx" => 0.101.0,
    #         "build-essential" => 1.0.2,
    #         "runit" => 0.15.0,
    #         "bluepill" => 1.0.4,
    #         "ohai" => 1.0.2
    #        }
    def resolve
      quietly { selector.find_solution(solution_constraints) }
    end

    # @param [#to_s] name
    #   name of the source to return
    #
    # @return [KCD::CookbookSource]
    def [](source)
      @sources[source.to_s]
    end
    alias_method :get_source, :[]

    # @param [#to_s] source
    #   the source to test if the resolver has added
    def has_source?(source)
      !get_source(source).nil?
    end

    private

      attr_reader :downloader
      attr_reader :graph

      # @param [#to_s] name
      #   name of the source to set
      # @param [CookbookSource] value
      #   source to set as value
      def []=(source, value)
        @sources[source.to_s] = value
      end
      alias_method :set_source, :[]=

      def selector
        Selector.new(graph)
      end

      def solution_constraints
        constraints = graph.packages.collect do |name, package|
          SolutionConstraint.new(package)
        end
      end

      # @param [String] name
      #   name of the package to add to the graph
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
  end
end
