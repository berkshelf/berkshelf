module Remy
  class Cheffile
    DEFAULT_FILENAME = 'Cheffile'

    class << self
      include DSL
      def read content
        # This will populate Remy.shelf. TODO: consider making this
        # build and return the shelf rather than building the shelf as
        # a side effect.
        instance_eval(content)
      end

      def process
        # TODO: friendly error message when the file doesn't exist
        read File.open(DEFAULT_FILENAME).read
        pp Remy.shelf.resolve_dependencies
        Remy.shelf.populate_cookbooks_directory
      end
    end
  end
end
