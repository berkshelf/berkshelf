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

    def process_install(without = nil)        
      if File.exist?(KCD::Lockfile::DEFAULT_FILENAME)
        filename = KCD::Lockfile::DEFAULT_FILENAME
        lockfile = true
      else
        filename = KCD::DEFAULT_FILENAME
        lockfile = false
      end

      KCD.shelf.exclude(without)
      KCD.shelf.download_sources
      KCD.shelf.resolve_dependencies
      KCD.shelf.populate_cookbooks_directory
      KCD.shelf.write_lockfile unless lockfile
    end
  end
end
