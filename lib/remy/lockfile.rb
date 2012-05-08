require 'remy/cookbookfile'

module Remy
  class Lockfile
    def initialize(cookbooks)
      @cookbooks = cookbooks
    end

    def write(filename = Remy::DEFAULT_FILENAME)
      content = @cookbooks.map do |cookbook|
                  get_cookbook_definition(cookbook)
                end.join("\n")
      File.write(filename + ".lock", content)
    end

    def get_cookbook_definition(cookbook)
      definition = "cookbook '#{cookbook.name}', :version => '#{cookbook.version}'"
      if cookbook.git_repo
        definition += ", :git => '#{cookbook.git_repo}', :ref => '#{cookbook.git_ref || 'HEAD'}'"
      end

      return definition
    end
  end
end
