begin
  require 'kitchen/cli'

  raise LoadError if Kitchen::VERSION < '1.0.0'

  module Berkshelf::Command
    class Test < ::Kitchen::CLI
      namespace 'test'
    end
  end

  Berkshelf::Cli.send(
    :register, Berkshelf::Command::Test,
    'test', 'test [COMMAND]', 'Testing task for your cookbook'
  )

  Berkshelf::InitGenerator.class_option(
    :skip_test_kitchen,
    type: :boolean,
    default: false,
    desc: 'Skip adding a testing environment to your cookbook'
  )
rescue LoadError
  # @author Seth Vargo <sethvargo@gmail.com>
  class Berkshelf::Cli
    desc 'test', 'test [COMMAND]', hide: true
    def test
      raise Berkshelf::MissingGemDependencyError.new('test-kitchen', '~> 1.0.0')
    end
  end
end
