require 'kitchen/cli'

module Berkshelf
  class TestCommand < Kitchen::CLI
    namespace "test"
  end

  class Cli
    register(TestCommand, 'test', 'test [COMMAND]', 'Testing tasks for your cookbook')
  end
end
