require 'remy/dsl'

module Remy
  class Cookbookfile
    class << self
      include DSL
      def read content
        # This will populate Remy.shelf. TODO: consider making this
        # build and return the shelf rather than building the shelf as
        # a side effect.
        instance_eval(content)
      end

      def process_install
        # TODO: friendly error message when the file doesn't exist
        
        filename = Remy::DEFAULT_FILENAME + ".lock"
        lockfile = false

        if File.exist?(filename)
          lockfile = true
        else
          filename = Remy::DEFAULT_FILENAME unless File.exist?(filename)
        end
          
        read File.open(filename).read
        Remy.shelf.resolve_dependencies
        Remy.shelf.populate_cookbooks_directory
        Remy.shelf.write_lockfile unless lockfile
      end
    end
  end
end
