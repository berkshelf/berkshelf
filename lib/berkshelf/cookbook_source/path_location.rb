module Berkshelf
  class CookbookSource
    # @author Jamie Winsor <jamie@vialstudios.com>
    class PathLocation
      include Location

      attr_accessor :path

      def initialize(name, options = {})
        @name = name
        @path = File.expand_path(options[:path])
        set_downloaded_status(true)
      end

      def download(destination)
        CachedCookbook.from_path(path)
      end

      def to_s
        "path: '#{path}'"
      end
    end
  end
end
