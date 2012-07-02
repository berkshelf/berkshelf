module Berkshelf
  # @author Jamie Winsor <jamie@vialstudios.com>
  class Resolver
    extend Forwardable
    include DepSelector

    def_delegator :@graph, :package
    def_delegator :@graph, :packages

    # @param [Downloader] downloader
    # @param [Array<CookbookSource>, CookbookSource] sources
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

      Array(sources).each do |source|
        add_source_dependencies(source)
      end
    end

    # Add the given source to the collection of sources for this instance
    # of Resolver. By default the dependencies of the given source will also
    # be added as sources to the collection.
    #
    # @param [Berkshelf::CookbookSource] source
    #   source to add
    # @param [Boolean] include_dependencies
    #   adds the dependencies of the given source as sources to the collection of
    #   if true. Dependencies will be ignored if false.
    #
    # @return [Array<CookbookSource>]
    def add_source(source, include_dependencies = true)
      if has_source?(source)
        raise DuplicateSourceDefined, "A source named '#{source.name}' is already present."
      end

      set_source(source)
      use_source(source) || install_source(source)

      package = add_package(source.name)
      package_version = add_version(package, Version.new(source.cached_cookbook.version))
      
      if include_dependencies
        add_source_dependencies(source)
      end

      sources
    end

    # Add the dependencies of the given source as sources in the collection of sources
    # on this instance of Resolver. Any dependencies which already have a source in the
    # collection of sources of the same name will not be added to the collection a second
    # time.
    #
    # @param [CookbookSource] source
    #   source to convert dependencies into sources
    #
    # @return [Array<CookbookSource>]
    def add_source_dependencies(source)
      source.cached_cookbook.dependencies.each do |name, constraint|
        next if has_source?(name)

        add_source(CookbookSource.new(name, constraint))
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

    # @param [CookbookSource, #to_s] source
    #   name of the source to return
    #
    # @return [Berkshelf::CookbookSource]
    def [](source)
      if source.is_a?(CookbookSource)
        source = source.name
      end
      @sources[source.to_s]
    end
    alias_method :get_source, :[]

    # @param [CoobookSource, #to_s] source
    #   the source to test if the resolver has added
    def has_source?(source)
      !get_source(source).nil?
    end

    private

      attr_reader :downloader
      attr_reader :graph

      # @param [CookbookSource] source
      def set_source(source)
        @sources[source.name] = source
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
