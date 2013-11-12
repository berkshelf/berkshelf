module Berkshelf
  class InitCommand < CLI
    parameter 'PATH', 'directory to initialize', default: '.'

    def execute
      require_relative '../generators/cookbook_generator'

      InitGenerator.new([path], options).invoke_all
    end
  end
end
