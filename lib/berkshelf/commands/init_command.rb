module Berkshelf
  class InitCommand < CLI
    parameter 'PATH', 'directory to initialize', default: '.'

    def execute
      InitGenerator.new(Array(path), options).invoke_all
    end

    def options
      {}
    end
  end
end
