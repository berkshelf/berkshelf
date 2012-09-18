require 'spec_helper'

module Berkshelf
  describe Formatters do
    before(:each) do
      @original = Formatters.class_variable_get :@@formatters
      Formatters.class_variable_set :@@formatters, Hash.new
    end

    after(:each) do
      Formatters.class_variable_set :@@formatters, @original
    end

    describe "ClassMethods" do
      subject { Formatters }
      let(:format_id) { :rspec }
      let(:format_klass) { Class.new }

      describe "::register" do
        it "adds the class of the includer to the list of registered formatters with the id" do
          subject.register(format_id, format_klass)

          subject.formatters.should have_key(format_id)
          subject.formatters[format_id].should eql(format_klass)
        end

        context "when given a string instead of a symbol as the ID" do
          it "converts the string to a symbol and registers it" do
            subject.register("rspec", format_klass)

            subject.formatters.should have_key(:rspec)
            subject.formatters[:rspec].should eql(format_klass)
          end
        end

        context "when a formatter of the given ID has already been registered" do
          it "raises an InternalError" do
            subject.register(format_id, format_klass)

            lambda {
              subject.register(format_id, format_klass)
            }.should raise_error(Berkshelf::InternalError)
          end
        end
      end

      describe "::formatters" do
        before(:each) do
          subject.register(format_id, format_klass)
        end

        it "returns a hash where formatter ID's are keys and values are formatter classes" do
          subject.formatters.should be_a(Hash)
          subject.formatters.should have(1).item
          subject.formatters.keys.first.should eql(format_id)
          subject.formatters.values.first.should eql(format_klass)
        end
      end

      describe "::get" do
        before(:each) do
          subject.register(format_id, format_klass)
        end

        it "returns the class constant of the given formatter ID" do
          subject[format_id].should eql(format_klass)
        end

        context "when the ID has not been registered" do
          it "returns nil" do
            subject[:not_there].should be_nil
          end
        end
      end
    end
  end

  describe Formatters::AbstractFormatter do
    before(:each) do
      @original = Formatters.class_variable_get :@@formatters
      Formatters.class_variable_set :@@formatters, Hash.new
    end

    after(:each) do
      Formatters.class_variable_set :@@formatters, @original
    end

    describe "ClassMethods" do
      subject do
        Class.new do
          include Formatters::AbstractFormatter
        end
      end

      describe "::register_formatter" do
        it "delegates to Formatters" do
          Formatters.should_receive(:register).with(:rspec, subject)

          subject.register_formatter(:rspec)
        end
      end
    end

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
      lambda { subject.msg("something you should know") }.should raise_error(AbstractFunction)
      lambda { subject.error("whoa this is bad") }.should raise_error(AbstractFunction)
    end
  end
end
