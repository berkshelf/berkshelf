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
      
      sources = KCD.shelf.sources(:permitted)
      resolver = Resolver.new(KCD.downloader, sources)
      resolver.resolve
      write_lockfile(resolver.sources) unless lockfile

      true
    end

    private

      def write_lockfile(sources)
        KCD::Lockfile.new(sources).write
      end
  end
end
