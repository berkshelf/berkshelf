require 'knife_cookbook_dependencies/cookbookfile'

module KnifeCookbookDependencies
  class Lockfile
    def initialize(cookbooks)
      @cookbooks = cookbooks
    end

    def write(filename = KnifeCookbookDependencies::DEFAULT_FILENAME)
      content = @cookbooks.map do |cookbook|
                  get_cookbook_definition(cookbook)
                end.join("\n")
      File.write(filename + ".lock", content)
    end

    def get_cookbook_definition(cookbook)
      definition = "cookbook '#{cookbook.name}', :locked_version => '#{cookbook.locked_version}'"
      if cookbook.git_repo
        definition += ", :git => '#{cookbook.git_repo}', :ref => '#{cookbook.git_ref || 'HEAD'}'"
      end

      return definition
    end
  end
end
