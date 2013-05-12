begin
  require 'kitchen/cli'

  module Berkshelf::Command
    class Test < ::Kitchen::CLI
      namespace 'test'
    end
  end

  Berkshelf::Cli.send(:register, Berkshelf::Command::Test, 'test', 'test [COMMAND]', 'Testing task for your cookbook')
rescue LoadError
  # @todo register a fake, hidden `test` command that instructs the user
  # to add test-kitcen to their Gemfile.
end
