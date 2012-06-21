require 'fileutils'

module Berkshelf
  # @author Jamie Winsor <jamie@vialstudios.com>
  class CookbookStore
    attr_reader :storage_path

    # Create a new instance of CookbookStore with the given
    # storage_path.
    #
    # @param [String] storage_path
    #   local filesystem path to the location to be initialized
    #   as a CookbookStore.
    def initialize(storage_path)
      @storage_path = Pathname.new(storage_path)
      initialize_filesystem
    end

    # Returns an instance of CachedCookbook representing the
    # Cookbook of your given name and version.
    #
    # @param [String] name
    #   name of the Cookbook you want to retrieve
    # @param [String] version
    #   version of the Cookbook you want to retrieve
    #
    # @return [Berkshelf::CachedCookbook]
    def cookbook(name, version)
      return nil unless downloaded?(name, version)

      path = cookbook_path(name, version)
      CachedCookbook.from_path(path)
    end

    # Returns an array of all of the Cookbooks that have been cached
    # to the storage_path of this instance of CookbookStore.
    #
    # @return [Array<Berkshelf::CachedCookbook>]
    def cookbooks
      [].tap do |cookbooks|
        storage_path.each_child do |p|
          cached_cookbook = CachedCookbook.from_path(p)
          
          cookbooks << cached_cookbook if cached_cookbook
        end
      end
    end

    # Returns an expanded path to the location on disk where the Cookbook
    # of the given name and version is located.
    #
    # @param [String] name
    # @param [String] version
    #
    # @return [Pathname]
    def cookbook_path(name, version)
      storage_path.join("#{name}-#{version}")
    end

    # Returns true if the Cookbook of the given name and verion is downloaded
    # to this instance of CookbookStore.
    #
    # @param [String] name
    # @param [String] version
    #
    # @return [Boolean]
    def downloaded?(name, version)
      cookbook_path(name, version).cookbook?
    end

    private

      def initialize_filesystem
        FileUtils.mkdir_p(storage_path, :mode => 0755)
      end
  end
end
