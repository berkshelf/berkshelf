require 'knife_cookbook_dependencies/dsl'

module KnifeCookbookDependencies
  class Cookbookfile
    class << self
      include DSL
      def read content
        # This will populate KnifeCookbookDependencies.shelf. TODO: consider making this
        # build and return the shelf rather than building the shelf as
        # a side effect.
        instance_eval(content)
      end

      def process_install
        # TODO: friendly error message when the file doesn't exist
        
        filename = KnifeCookbookDependencies::DEFAULT_FILENAME + ".lock"
        lockfile = false

        if File.exist?(filename)
          lockfile = true
        else
          filename = KnifeCookbookDependencies::DEFAULT_FILENAME unless File.exist?(filename)
        end

        begin
          read File.open(filename).read
        rescue Errno::ENOENT => e
          KnifeCookbookDependencies.ui.fatal ErrorMessages.missing_cookbookfile
          exit 100
        end
        KnifeCookbookDependencies.shelf.resolve_dependencies
        KnifeCookbookDependencies.shelf.populate_cookbooks_directory
        KnifeCookbookDependencies.shelf.write_lockfile unless lockfile
      end
    end
  end
end
