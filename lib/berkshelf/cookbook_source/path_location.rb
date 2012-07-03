module Berkshelf
  class CookbookSource
    # @author Jamie Winsor <jamie@vialstudios.com>
    class PathLocation
      include Location

      attr_accessor :path

      # @param [#to_s] name
      # @param [DepSelector::VersionConstraint] version_constraint
      # @param [Hash] options
      def initialize(name, version_constraint, options = {})
        @name = name
        @version_constraint = version_constraint
        @path = File.expand_path(options[:path])
        set_downloaded_status(true)
      end

      # @param [#to_s] destination
      #
      # @return [String]
      #   path to the downloaded source
      def download(destination)
        validate_downloaded!(path)

        set_downloaded_status(true)
        CachedCookbook.from_path(path)
      end

      def to_s
        "path: '#{path}'"
      end
    end
  end
end
