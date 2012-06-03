module KnifeCookbookDependencies
  class Cookbookfile
    include DSL

    class << self
      def from_file(file)
        content = File.read(file)
        read(content)
      rescue Errno::ENOENT => e
        raise CookbookfileNotFound, "No Cookbookfile or Cookbookfile.lock found at: #{file}."
      end

      def read(content)
        object = new
        object.instance_eval(content)

        object
      end
    end

    def process_install(options = {})
      if File.exist?(KCD::Lockfile::DEFAULT_FILENAME)
        filename = KCD::Lockfile::DEFAULT_FILENAME
        lockfile = true
      else
        filename = KCD::DEFAULT_FILENAME
        lockfile = false
      end

      KCD.shelf.exclude(options[:without])
      
      results = KCD.shelf.download_sources
      if results.has_errors?
        raise DownloadFailure.new(results.failed)
      end

      sources = KCD.shelf.sources(:permitted)
      Resolver.new(KCD.downloader, sources).resolve
      KCD.shelf.write_lockfile unless lockfile

      true
    end
  end
end
