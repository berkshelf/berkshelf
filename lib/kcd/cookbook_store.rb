module KnifeCookbookDependencies
  class CookbookStore
    attr_reader :storage_path
    attr_accessor :downloader
    attr_accessor :uploader

    def initialize(storage_path)
      @storage_path = Pathname.new(storage_path)
      initialize_filesystem

      @downloader = Downloader.new(storage_path)
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
