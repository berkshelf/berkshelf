require 'knife_cookbook_dependencies/alias'
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
        
        filename = KCD::DEFAULT_FILENAME + ".lock"
        lockfile = false

        if File.exist?(filename)
          lockfile = true
        else
          filename = KCD::DEFAULT_FILENAME unless File.exist?(filename)
        end
          
        read File.read(filename)
        KCD.shelf.resolve_dependencies
        KCD.shelf.populate_cookbooks_directory
        KCD.shelf.write_lockfile unless lockfile
      end
    end
  end
end
