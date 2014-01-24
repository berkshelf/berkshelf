module Berkshelf
  class Resolver
    class Graph < Solve::Graph
      # @param [Berkshelf::CookbookStore] store
      def populate_store(store = nil)
        store ||= Berkshelf::CookbookStore.instance

        store.cookbooks.each do |cookbook|
          artifacts(cookbook.cookbook_name, cookbook.version)
        end
      end

      # Add dependencies of a locally cached cookbook to the graph
      #
      # @param [Berkshelf::CachedCookbook] cookbook
      #
      # @return [Hash]
      def populate_local(cookbook)
        name    = cookbook.cookbook_name
        version = cookbook.version

        artifacts(name, version)
        cookbook.dependencies.each do |dependency, constraint|
          artifacts(name, version).depends(dependency, constraint)
        end
      end

      # @param [Array<Berkshelf::Source>, Berkshelf::Source] sources
      def populate(sources)
        universe(sources).each do |cookbook|
          next if has_artifact?(cookbook.name, cookbook.version)

          artifacts(cookbook.name, cookbook.version)

          cookbook.dependencies.each do |dependency, constraint|
            artifacts(cookbook.name, cookbook.version).depends(dependency, constraint)
          end
        end
      end

      # @param [Array<Berkshelf::Source>, Berkshelf::Source] sources
      #
      # @return [Array<Berkshelf::RemoteCookbook>]
      def universe(sources)
        cookbooks = []
        Array(sources).each { |source| cookbooks = cookbooks | source.universe }
        cookbooks
      end
    end
  end
end
