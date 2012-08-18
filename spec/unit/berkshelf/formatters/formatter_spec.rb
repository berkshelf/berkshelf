require 'spec_helper'
require 'berkshelf/formatters/formatter'

module Berkshelf
  module Formatters
    class TestFormatter
      include Formatter
    end

    describe Formatter do
      
      subject { TestFormatter.new }

      it "has abstract methods for all the messaging modes" do
        lambda { subject.install("my_coobook","1.2.3","http://community") }.should raise_error(MethodNotImplmentedError)
        lambda { subject.install("my_coobook","1.2.3","http://community",:cached) }.should raise_error(MethodNotImplmentedError)
        lambda { subject.upload("my_coobook","1.2.3","http://chef_server") }.should raise_error(MethodNotImplmentedError)
        lambda { subject.shims_written("/Users/jcocktosten") }.should raise_error(MethodNotImplmentedError)
        lambda { subject.msg("something you should know") }.should raise_error(MethodNotImplmentedError)
        lambda { subject.error("whoa this is bad") }.should raise_error(MethodNotImplmentedError)
      end
    end
  end
end
