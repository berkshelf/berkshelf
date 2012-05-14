require 'knife_cookbook_dependencies/alias'

module KnifeCookbookDependencies
  module DSL
    def cookbook *args
      KCD.shelf.shelve_cookbook *args
    end
  end
end
