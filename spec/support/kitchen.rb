module Berkshelf
  module RSpec
    module Kitchen
      require 'kitchen/generator/init'

      def stub_kitchen!
        generator = double('kitchen-generator', invoke_all: nil)
        ::Kitchen::Generator::Init.stub(:new).with(any_args()).and_return(generator)
      end
    end
  end
end
