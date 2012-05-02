module Remy
  module DSL
    def cookbook *args
      Remy.shelf.shelve_cookbook *args
    end
  end
end
