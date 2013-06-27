module Berkshelf
  class Resolver
    class Graph < Solve::Graph
      # @param [Array<Berkshelf::Source>, Berkshelf::Source] sources
      def populate(sources)
        universe(sources).each do |cookbook|
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
