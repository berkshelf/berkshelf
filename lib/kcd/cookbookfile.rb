module KnifeCookbookDependencies
  class Cookbookfile
    class << self
      include DSL

      def read(content)
        # This will populate KnifeCookbookDependencies.shelf. TODO: consider making this
        # build and return the shelf rather than building the shelf as
        # a side effect.
        instance_eval(content)
      end

      def process_install(without=nil)
        # TODO: friendly error message when the file doesn't exist
        
        filename = KCD::DEFAULT_FILENAME + ".lock"
        lockfile = false

        if File.exist?(filename)
          lockfile = true
        else
          filename = KCD::DEFAULT_FILENAME unless File.exist?(filename)
        end

        begin
          read File.read(filename)
        rescue Errno::ENOENT => e
          KCD.ui.fatal ErrorMessages.missing_cookbookfile
          exit 100
        end

        KCD.exclude(without)
        KCD.shelf.resolve_dependencies
        KCD.shelf.populate_cookbooks_directory
        KCD.shelf.write_lockfile unless lockfile
      end
    end
  end
end
