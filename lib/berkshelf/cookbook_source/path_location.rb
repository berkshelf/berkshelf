module Berkshelf
  class CookbookSource
    # @author Jamie Winsor <jamie@vialstudios.com>
    class PathLocation
      include Location

      attr_accessor :path

      # @param [#to_s] name
      # @param [Solve::Constraint] version_constraint
      # @param [Hash] options
      #
      # @option options [String] :path
      #   a filepath to the cookbook on your local disk
      def initialize(name, version_constraint, options = {})
        @name = name
        @version_constraint = version_constraint
        @path = File.expand_path(options[:path])
        set_downloaded_status(true)
      end

      # @param [#to_s] destination
      #
      # @return [Berkshelf::CachedCookbook]
      def download(destination)
        cached = CachedCookbook.from_path(path)
        validate_cached(cached)

        set_downloaded_status(true)
        cached
      end

      def to_s
        "path: '#{path}'"
      end
    end
  end
end
