require 'kitchen/cli'

module Berkshelf
  class TestCommand < Kitchen::CLI
    namespace "test"
  end
end
