module Berkshelf
  class CookbookCommand < CLI
    parameter 'NAME', 'cookbook name'

    def execute
      require_relative '../generators/cookbook_generator'

      path = File.join(Dir.pwd, name)
      CookbookGenerator.new([path, name], options).invoke_all
    end
  end
end
