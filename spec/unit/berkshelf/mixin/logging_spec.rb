require 'spec_helper'

describe Berkshelf::Mixin::Logging do
  subject do
    Class.new { include Berkshelf::Mixin::Logging }.new
  end

  describe '#log' do
    it 'returns the Berkshelf::Logger' do
      expect(subject.log).to eq(Berkshelf::Logger)
    end
  end

  describe '#log_exception' do
    it 'logs the exception and backtrace as fatal' do
      ex = Exception.new('msg')
      ex.stub(:backtrace).and_return(['one', 'two'])
      subject.log.should_receive(:fatal).exactly(2).times

      subject.log_exception(ex)
    end
  end
end
