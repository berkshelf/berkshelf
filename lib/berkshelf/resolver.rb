module Berkshelf
  # @author Jamie Winsor <jamie@vialstudios.com>
  class Resolver
    extend Forwardable
    include DepSelector

    def_delegator :@graph, :package
    def_delegator :@graph, :packages

    def initialize(downloader, sources = Array.new)
      @downloader = downloader
      @graph = DependencyGraph.new
      @sources = Hash.new

      # Dependencies need to be added AFTER the sources. If they are
      # not, then one of the dependencies of a source that is added
      # may take precedence over an explicitly set source that appears
      # later in the iterator.
      Array(sources).each do |source|
        add_source(source, false)
      end
      add_sources_dependencies
    end

    # @param [Berkshelf::CookbookSource] source
    #   source to add
    # @param [Boolean] include_dependencies
    #   if true, after adding the source the dependencies defined in the
    #   sources metadata will be added to the graph and downloaded
    #
    # @return [DepSelector::PackageVersion]
    def add_source(source, include_dependencies = true)
      raise DuplicateSourceDefined if has_source?(source)

      set_source(source.name, source)

      use_source(source) || install_source(source)

      package = add_package(source.name)
      package_version = add_version(package, Version.new(source.cached_cookbook.version))
      
      add_dependencies(package_version, source.cached_cookbook.dependencies) if include_dependencies

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

          use_source(source) || install_source(source)

          dep_pkgver = add_version(dep_package, Version.new(source.cached_cookbook.version))
          add_dependencies(dep_pkgver, source.cached_cookbook.dependencies)
          set_source(source.name, source)
        end
      end
    end

    # @return [Array<Berkshelf::CookbookSource>]
    #   an array of CookbookSources that are currently added to this resolver
    def sources
      @sources.collect { |name, source| source }
    end

    # Finds a solution for the currently added sources and their dependencies and
    # returns an array of CachedCookbooks.
    #
    # @return [Array<Berkshelf::CachedCookbook>]
    def resolve
      solution = quietly { selector.find_solution(solution_constraints) }

      [].tap do |cached_cookbooks|
        solution.each do |name, version|
          cached_cookbooks << get_source(name).cached_cookbook
        end
      end
    end

    # @param [#to_s] source
    #   name of the source to return
    #
    # @return [Berkshelf::CookbookSource]
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

      # @param [#to_s] source
      #   name of the source to set
      # @param [CookbookSource] value
      #   source to set as value
      def set_source(source, value)
        @sources[source.to_s] = value
      end

      # @param [Berkshelf::CookbookSource] source
      #
      # @return [Boolean]
      def install_source(source)
        downloader.download!(source)
        Berkshelf.ui.info "Installing #{source.name} (#{source.cached_cookbook.version}) from #{source.location}"
      end

      # @param [Berkshelf::CookbookSource] source
      #
      # @return [Boolean]
      def use_source(source)
        if source.downloaded?
          cached = source.cached_cookbook
        else
          cached = downloader.cookbook_store.satisfy(source.name, source.version_constraint)
          return false if cached.nil?

          get_source(source).cached_cookbook = cached
        end

        msg = "Using #{cached.cookbook_name} (#{cached.version})"
        msg << " at #{source.location}" if source.location.is_a?(CookbookSource::PathLocation)
        Berkshelf.ui.info msg

        true
      end

      def selector
        Selector.new(graph)
      end

      def solution_constraints
        constraints = graph.packages.collect do |name, package|
          SolutionConstraint.new(package)
        end
      end

      # Add the dependencies of each source to the graph
      def add_sources_dependencies
        sources.each do |source|
          package_version = package(source.name)[Version.new(source.cached_cookbook.version)]
          add_dependencies(package_version, source.cached_cookbook.dependencies)
        end
      end

      # @param [String] name
      #   name of the package to add to the graph
      def add_package(name)
        graph.package(name)
      end

      # Add a version to a package
      #
      # @param [DepSelector::Package] package
      #   the package to add a version to
      # @param [DepSelector::Version] version
      #   the version to add the the package
      def add_version(package, version)
        package.add_version(version)
      end
  end
end
