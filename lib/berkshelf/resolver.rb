module Berkshelf
  class Resolver
    require_relative 'resolver/graph'

    extend Forwardable

    # @return [Berkshelf::Berksfile]
    attr_reader :berksfile

    # @return [Resolver::Graph]
    attr_reader :graph

    # @return [Array<Berkshelf::Dependency>]
    #   an array of dependencies that must be satisfied
    attr_reader :demands

    # @param [Berkshelf::Berksfile] berksfile
    # @param [Array<Berkshelf::Dependency>, Berkshelf::Dependency] demands
    #   a dependency, or array of dependencies, which must be satisfied
    def initialize(berksfile, demands = [])
      @berksfile = berksfile
      @graph     = Graph.new
      @demands   = Array.new

      Array(demands).each { |demand| add_demand(demand) }
    end

    # Add the given dependency to the collection of demands
    #
    # @param [Berkshelf::Dependency] demand
    #   add a dependency that must be satisfied to the graph
    #
    # @raise [DuplicateDemand]
    #
    # @return [Array<Berkshelf::Dependency>]
    def add_demand(demand)
      if has_demand?(demand)
        raise DuplicateDemand, "A demand named '#{demand.name}' is already present."
      end

      demands.push(demand)
    end

    # Add dependencies of a locally cached cookbook which will take precedence over anything
    # found in the universe.
    #
    # @param [Berkshelf::CachedCookbook] cookbook
    #
    # @return [Hash]
    def add_explicit_dependencies(cookbook)
      graph.populate_local(cookbook)
    end

    # An array of arrays containing the name and constraint of each demand
    #
    # @note this is the format that Solve uses to determine a solution for the graph
    #
    # @return [Array<String, String>]
    def demand_array
      demands.collect { |demand| [ demand.name, demand.version_constraint ] }
    end

    # Finds a solution for the currently added dependencies and their dependencies and
    # returns an array of CachedCookbooks.
    #
    # @raise [Berkshelf::NoSolutionError] when a solution could not be found for the given demands
    #
    # @return [Array<Array<String, String, Dependency>>]
    def resolve
      graph.populate_store
      graph.populate(berksfile.sources)

      Solve.it!(graph, demand_array, ENV['DEBUG_RESOLVER'] ? { ui: Berkshelf.ui } : {}).collect do |name, version|
        dependency = get_demand(name) || Dependency.new(berksfile, name)
        dependency.locked_version = version

        dependency
      end
    rescue Solve::Errors::NoSolutionError
      raise Berkshelf::NoSolutionError.new(demands)
    end

    # Retrieve the given demand from the resolver
    #
    # @param [Berkshelf::Dependency, #to_s] demand
    #   name of the dependency to return
    #
    # @return [Berkshelf::Dependency]
    def [](demand)
      name = demand.respond_to?(:name) ? demand.name : demand.to_s
      demands.find { |demand| demand.name == name }
    end
    alias_method :get_demand, :[]

    # Check if the given demand has been added to the resolver
    #
    # @param [Berkshelf::Dependency, #to_s] demand
    #   the demand or the name of the demand to check for
    def has_demand?(demand)
      !get_demand(demand).nil?
    end
  end
end
