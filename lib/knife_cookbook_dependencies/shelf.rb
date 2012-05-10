require 'knife_cookbook_dependencies/lockfile'

module KnifeCookbookDependencies
  class Shelf
    META_COOKBOOK_NAME = 'cookbook_dependencies_shelf'

    attr_accessor :cookbooks, :active_group, :excluded_groups

    def initialize
      @cookbooks = []
    end
    
    def shelve_cookbook(*args)
      @cookbooks << (args.first.is_a?(Cookbook) ? args.first : Cookbook.new(*args))
    end

    def resolve_dependencies
      graph = DepSelector::DependencyGraph.new

      post_exclusions = requested_cookbooks
      cookbooks_to_install = @cookbooks.select {|c| post_exclusions.include?(c.name)}
      # all cookbooks in the Cookbookfile are dependencies of the shelf
      shelf = MetaCookbook.new(META_COOKBOOK_NAME, cookbooks_to_install)

      self.class.populate_graph graph, shelf

      selector = DepSelector::Selector.new(graph)
      solution = selector.find_solution([DepSelector::SolutionConstraint.new(graph.package(META_COOKBOOK_NAME))])
      solution.delete META_COOKBOOK_NAME
      solution
    end

    def write_lockfile
      KnifeCookbookDependencies::Lockfile.new(@cookbooks).write
    end

    def get_cookbook(name)
      @cookbooks.select { |c| c.name == name }.first
    end

    def populate_cookbooks_directory
      cookbooks_from_path = @cookbooks.select(&:from_path?) | @cookbooks.select(&:from_git?)
      
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

    def cookbook_groups
      {}.tap do |groups|
        @cookbooks.each do |cookbook|
          cookbook.groups.each do |group|
            groups[group] ||= []
            groups[group] << cookbook.name
          end
        end
      end
    end

    def requested_cookbooks
      return @cookbooks.collect(&:name) unless @excluded_groups
      [].tap do |r|
        cookbook_groups.each do |group, cookbooks|
          r << cookbooks unless @excluded_groups.include?(group.to_sym)
        end
      end.flatten.uniq
    end

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
  end
end
