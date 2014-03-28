require 'spec_helper'

describe Berkshelf::Logger do
  %w(info warn error fatal debug deprecate exception).each do |meth|
    describe "##{meth}" do
      it 'responds' do
        expect(subject).to respond_to(meth.to_sym)
      end
    end
  end
end
