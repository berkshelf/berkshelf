require 'spec_helper'

describe Berkshelf::Mixin::Logging do
  subject do
    Class.new do
      include Berkshelf::Mixin::Logging
    end.new
  end

  describe "#log" do
    it "returns the Berkshelf::Logger" do
      subject.log.should eql(Berkshelf::Logger)
    end
  end

  describe "#log_exception" do
    it "logs the exception and it's backtrace as fatal" do
      ex = Exception.new('msg')
      ex.stub(:backtrace).and_return(['one', 'two'])
      subject.log.should_receive(:fatal).exactly(2).times

      subject.log_exception(ex)
    end
  end
end
