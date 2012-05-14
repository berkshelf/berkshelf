module KnifeCookbookDependencies
  module DSL
    def cookbook(*args)
      KCD.shelf.shelve_cookbook(*args)
    end
  end
end
