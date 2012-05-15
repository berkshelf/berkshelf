module KnifeCookbookDependencies
  class DependencyReader
    attr_reader :dependency_list, :cookbook
    
    def initialize(cookbook)
      @cookbook = cookbook
      @dependency_list = []
    end

    def read
      @cookbook.metadata.dependencies.each { |name, constraint| depends(name, constraint) }
      @dependency_list
    end
    
    def depends(*args)
      name, constraint = args

      dependency_cookbook = KCD.shelf.get_cookbook(name) || get_dependency(name)
      if dependency_cookbook
        dependency_cookbook.add_version_constraint constraint
      else
        @dependency_list << Cookbook.new(*args) 
      end
    end

    def get_dependency(name)
      @dependency_list.select { |c| c.name == name }.first
    end
  end
end
