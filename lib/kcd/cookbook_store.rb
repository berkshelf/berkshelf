module KnifeCookbookDependencies
  class CookbookStore
    attr_reader :storage_path

    def initialize(storage_path)
      @storage_path = Pathname.new(storage_path)
      initialize_filesystem
    end

    def cookbooks
      [].tap do |cookbooks|
        storage_path.each_child do |p|
          cached_cookbook = CachedCookbook.from_path(p)
          
          cookbooks << cached_cookbook if cached_cookbook
        end
      end
    end

    def cookbook_path(name, version)
      storage_path.join("#{name}-#{version}")
    end

    def downloaded?(name, version)
      cookbook_path(name, version).cookbook?
    end

    private

      def initialize_filesystem
        FileUtils.mkdir_p(storage_path, :mode => 0755)
      end
  end
end
