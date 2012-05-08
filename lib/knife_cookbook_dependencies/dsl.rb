module KnifeCookbookDependencies
  module DSL
    def cookbook *args
      KnifeCookbookDependencies.shelf.shelve_cookbook *args
    end
  end
end
