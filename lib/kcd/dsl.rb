module KnifeCookbookDependencies
  module DSL
    def cookbook(*args)
      KCD.shelf.shelve_cookbook(*args)
    end

    def group *args
      KCD.shelf.active_group = args
      yield
      KCD.shelf.active_group = nil
    end
  end
end
