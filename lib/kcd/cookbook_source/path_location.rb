module KnifeCookbookDependencies
  class CookbookSource
    # @internal
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

      def downloaded?(destination)
        if File.exists?(path) && File.chef_cookbook?(path)
          path
        else
          nil
        end
      end

      def to_s
        "path: '#{path}'"
      end
    end
  end
end
