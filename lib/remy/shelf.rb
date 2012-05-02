module Remy
  class Shelf
    attr_accessor :cookbooks

    def initialize
      @cookbooks = []
    end
    
    def shelve_cookbook(name, version_constraint=nil)
      @cookbooks << Cookbook.new(name, version_constraint)
    end

    def resolve_dependencies
      graph = DepSelector::DependencyGraph.new
      shelf = MetaCookbook.new('remy_shelf', @cookbooks) # all cookbooks in the
                                             # Cheffile are dependencies
                                             # of the shelf

      self.class.populate_graph graph, shelf
    end

    def self.populate_graph(graph, cookbook)
      package = graph.package cookbook.name
      cookbook.versions.each { |v| package.add_version(v) }

      cookbook.dependencies.each do |dependency|
        graph = populate_graph(graph, dependency)
        dep = graph.packages[dependency.name]
        version = package.versions.select { |v| v.version == cookbook.latest_constrained_version }.first
        version.dependencies << DepSelector::Dependency.new(dep, dependency.version_constraint)
      end

      graph
    end

    def lockfile
      resolve_dependencies!
      
      # TODO: loop over dep graph and build lockfile
    end
  end
end
