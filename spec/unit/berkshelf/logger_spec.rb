require 'spec_helper'

describe Berkshelf::Logger do
  %w(info warn error fatal debug deprecate).each do |meth|
    describe "##{meth}" do
      it 'responds' do
        expect(Berkshelf::Logger).to respond_to(meth.to_sym)
      end
    end
  end
end
