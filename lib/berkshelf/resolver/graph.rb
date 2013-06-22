module Berkshelf
  class Resolver
    class Graph < Solve::Graph
      # @param [Array<SourceURI>, SourceURI] sources
      def populate(sources)
        universe(sources).each do |name, versions|
          versions.each do |version, metadata|
            artifacts(name, version)

            metadata[:dependencies].each do |dependency, constraint|
              artifacts(name, version).depends(dependency, constraint)
            end
          end
        end
      end

      # @param [Array<SourceURI>, SourceURI] sources
      #
      # @return [Hash]
      def universe(sources)
        {}.tap do |universe|
          Array(sources).each { |source| universe.merge!(APIClient.new(source).universe) }
        end
      end
    end
  end
end
