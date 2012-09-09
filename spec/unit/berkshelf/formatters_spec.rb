require 'spec_helper'

module Berkshelf
  describe Formatters::AbstractFormatter do
    subject do
      Class.new do
        include Formatters::AbstractFormatter
      end.new
    end

    it "has abstract methods for all the messaging modes" do
      lambda { subject.install("my_coobook","1.2.3","http://community") }.should raise_error(AbstractFunction)
      lambda { subject.use("my_coobook","1.2.3") }.should raise_error(AbstractFunction)
      lambda { subject.use("my_coobook","1.2.3","http://community") }.should raise_error(AbstractFunction)
      lambda { subject.upload("my_coobook","1.2.3","http://chef_server") }.should raise_error(AbstractFunction)
      lambda { subject.shims_written("/Users/jcocktosten") }.should raise_error(AbstractFunction)
      lambda { subject.msg("something you should know") }.should raise_error(AbstractFunction)
      lambda { subject.error("whoa this is bad") }.should raise_error(AbstractFunction)
    end
  end
end
