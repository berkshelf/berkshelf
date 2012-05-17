module KnifeCookbookDependencies
  class Lockfile
    DEFAULT_FILENAME = "#{KCD::DEFAULT_FILENAME}.lock"

    def initialize(cookbooks)
      @cookbooks = cookbooks
    end

    def write(filename = DEFAULT_FILENAME)
      content = @cookbooks.map do |cookbook|
                  get_cookbook_definition(cookbook)
                end.join("\n")
      File.open(DEFAULT_FILENAME, "wb") { |f| f.write content }
    end

    def get_cookbook_definition(cookbook)
      definition = "cookbook '#{cookbook.name}'"

      if cookbook.from_git?
        definition += ", :git => '#{cookbook.git_repo}', :ref => '#{cookbook.git_ref || 'HEAD'}'"
      elsif cookbook.from_path?
        definition += ", :path => '#{cookbook.local_path}'"
      else
        definition += ", :locked_version => '#{cookbook.locked_version}'"
      end

      return definition
    end

    def remove!
      self.class.remove!
    end

    class << self
      def remove!
        FileUtils.rm_f DEFAULT_FILENAME
      end
    end
  end
end
