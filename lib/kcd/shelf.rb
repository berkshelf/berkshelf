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

    attr_accessor :active_group
    attr_accessor :excluded_groups

    def initialize
      @sources = Hash.new
    end

    def sources(scope = :all)
      case scope
      when :all; @sources.collect { |name, source| source }.flatten
      when :permitted; get_permitted_sources
      when :excluded; get_excluded_sources
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
      sources.each { |source| KCD.downloader.enqueue(source) }
      KCD.downloader.download_all
    end

    def exclude(groups)
      groups = groups.to_s.split(/[,:]/) unless groups.is_a?(Array)
      @excluded_groups = groups.collect {|c| c.to_sym}
    end

    def groups
      {}.tap do |groups|
        @sources.each_pair do |name, source|
          source.groups.each do |group|
            groups[group] ||= []
            groups[group] << source
          end
        end
      end
    end

    # @param [String] name
    #   name of the source to return
    def [](name)
      @sources[name]
    end
    alias_method :get_source, :[]

    private

      def get_permitted_sources
        g = groups.delete_if { |name, source| excluded_groups.include?(name) }
        g.collect { |name, source| source }.flatten
      end

      def get_excluded_sources
        g = groups.delete_if { |name, source| !excluded_groups.include?(name) }
        g.collect { |name, source| source }.flatten
      end
  end
end
