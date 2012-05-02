module Remy
  class Cheffile
    class << self
      include DSL
      def read content
        # This will populate Remy.shelf. TODO: consider making this
        # build and return the shelf rather than building the shelf as
        # a side effect.
        instance_eval(content)
      end
    end
  end
end
