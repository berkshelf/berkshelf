module Berkshelf
  # @author Jamie Winsor <reset@riotgames.com>
  class CachedCookbook < Ridley::Chef::Cookbook
    class << self
      # Creates a new instance of Berkshelf::CachedCookbook from a path on disk that
      # contains a Cookbook. The name of the Cookbook will be determined first by the
      # name attribute of the metadata.rb file if it is present. If the name attribute
      # has not been set the Cookbook name will be determined by the basename of the
      # given filepath.
      #
      # @param [#to_s] path
      #   a path on disk to the location of a Cookbook
      #
      # @return [Berkshelf::CachedCookbook]
      def from_path(path, specified_name = nil)
        path = Pathname.new(File.expand_path(path))
        metadata = Chef::Cookbook::Metadata.new

        begin
          metadata.from_file(path.join("metadata.rb").to_s)
        rescue IOError
          raise CookbookNotFound, "No 'metadata.rb' file found at: '#{path}'"
        end

        name = specified_name || metadata.name.presence || File.basename(path)
        metadata.name(name) if metadata.name.empty?

        new(name, path, metadata)
      end

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
