module Berkshelf
  # @author Jamie Winsor <reset@riotgames.com>
  class CachedCookbook < Ridley::Chef::Cookbook
    class << self
      # @param [#to_s] path
      #   a path on disk to the location of a Cookbook downloaded by the Downloader
      #
      # @return [CachedCookbook]
      #   an instance of CachedCookbook initialized by the contents found at the
      #   given path.
      def from_store_path(path)
        path        = Pathname.new(path)
        cached_name = File.basename(path.to_s).slice(DIRNAME_REGEXP, 1)
        return nil if cached_name.nil?

        from_path(path, name: cached_name)      
      end
    end

    DIRNAME_REGEXP = /^(.+)-(.+)$/

    # @return [Hash]
    def dependencies
      metadata.recommendations.merge(metadata.dependencies)
    end
  end
end
