module KnifeCookbookDependencies
  module DSL
    def cookbook *args
      KnifeCookbookDependencies.shelf.shelve_cookbook *args
    end

    def group *args
      KnifeCookbookDependencies.shelf.active_group = args
      yield
      KnifeCookbookDependencies.shelf.active_group = nil
    end
  end
end
