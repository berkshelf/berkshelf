module KnifeCookbookDependencies
  class Shelf
    class << self
      def populate_graph(graph, cookbook)
        package = graph.package cookbook.name
        cookbook.versions.each { |v| package.add_version(v) }
        cookbook.dependencies.each do |dependency|
          graph = populate_graph(graph, dependency)
          dep = graph.package(dependency.name)
          version = package.versions.select { |v| v.version == cookbook.latest_constrained_version }.first
          dependency.version_constraints.each do |constraint|
            version.dependencies << DepSelector::Dependency.new(dep, constraint)
          end
        end

        graph
      end
    end

    META_COOKBOOK_NAME = 'cookbook_dependencies_shelf'

    attr_reader :sources
    attr_accessor :active_group
    attr_accessor :excluded_groups

    def initialize
      @sources = Hash.new
    end

    def sources(scope = :all)
      case scope
      when :all; @sources
      when :permitted; get_permitted_sources
      else
        raise ArgumentError, "Unknown scope #{scope}"
      end
    end

    def add_source(source)
      @sources[source.to_s] = source
    end

    def remove_source(source)
      @sources.delete(source.to_s)
    end

    def has_source?(source)
      @sources.has_key?(source.to_s)
    end

    def download_sources
      sources.each { |name, source| KCD.downloader.enqueue(source) }
      KCD.downloader.download
    end

    def resolve_dependencies
      graph = DepSelector::DependencyGraph.new

      permitted_sources = sources(:permitted)

      # all cookbooks in the Cookbookfile are dependencies of the shelf
      shelf = MetaCookbook.new(META_COOKBOOK_NAME, permitted_sources)

      self.class.populate_graph graph, shelf

      selector = DepSelector::Selector.new(graph)

      solution = quietly do
        selector.find_solution([DepSelector::SolutionConstraint.new(graph.package(META_COOKBOOK_NAME))])
      end

      solution.delete META_COOKBOOK_NAME
      solution
    end

    def write_lockfile
      KCD::Lockfile.new(@cookbooks).write
    end

    def populate_cookbooks_directory
      cookbooks_from_path = @cookbooks.select(&:from_path?) | @cookbooks.select(&:from_git?)
      KCD.ui.info "Fetching cookbooks:"
      resolve_dependencies.each_pair do |cookbook_name, version|
        cookbook = cookbooks_from_path.select { |c| c.name == cookbook_name }.first || Cookbook.new(cookbook_name, version.to_s)
        @cookbooks << cookbook
        cookbook.download
        cookbook.unpack
        cookbook.copy_to_cookbooks_directory
        cookbook.locked_version = version
      end
      @cookbooks = @cookbooks.uniq.reject { |x| x.locked_version.nil? }
    end

    def exclude(groups)
      groups = groups.to_s.split(/[,:]/) unless groups.is_a?(Array)
      @excluded_groups = groups.collect {|c| c.to_sym}
    end

    def groups
      {}.tap do |groups|
        sources.each_pair do |name, source|
          source.groups.each do |group|
            groups[group] ||= []
            groups[group] << source.name
          end
        end
      end
    end

    # remove
    # def requested_cookbooks
    #   return @cookbooks.collect(&:name) unless @excluded_groups
    #   [].tap do |r|
    #     cookbook_groups.each do |group, cookbooks|
    #       r << cookbooks unless @excluded_groups.include?(group.to_sym)
    #     end
    #   end.flatten.uniq
    # end

    private

      def get_permitted_sources
        s = @sources.clone
        s.delete_if { |name, source| source.has_group?(excluded_groups) }
        s
      end
  end
end
