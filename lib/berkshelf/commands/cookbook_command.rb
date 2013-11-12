module Berkshelf
  class CookbookCommand < CLI
    parameter 'NAME', 'cookbook name'

    def execute
      path = File.join(Dir.pwd, name)
      CookbookGenerator.new([path, name], options).invoke_all
    end

    def options
      {}
    end
  end
end
