module KnifeCookbookDependencies
  class CookbookSource
    # @author Jamie Winsor <jamie@vialstudios.com>
    class PathLocation
      include Location

      attr_accessor :path

      def initialize(name, options = {})
        @name = name
        @path = File.expand_path(options[:path])
      end

      def download(destination)
        unless File.chef_cookbook?(path)
          raise CookbookNotFound, "Cookbook '#{name}' not found at path: '#{path}'"
        end

        path
      end

      def to_s
        "path: '#{path}'"
      end
    end
  end
end
