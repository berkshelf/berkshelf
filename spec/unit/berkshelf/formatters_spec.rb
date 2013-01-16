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

          expect(subject.formatters).to have_key(format_id)
          expect(subject.formatters[format_id]).to eql(format_klass)
        end

        context "when given a string instead of a symbol as the ID" do
          it "converts the string to a symbol and registers it" do
            subject.register("rspec", format_klass)

            expect(subject.formatters).to have_key(:rspec)
            expect(subject.formatters[:rspec]).to eql(format_klass)
          end
        end

        context "when a formatter of the given ID has already been registered" do
          it "raises an InternalError" do
            subject.register(format_id, format_klass)

            expect {
              subject.register(format_id, format_klass)
            }.to raise_error(Berkshelf::InternalError)
          end
        end
      end

      describe "::formatters" do
        before(:each) do
          subject.register(format_id, format_klass)
        end

        it "returns a hash where formatter ID's are keys and values are formatter classes" do
          expect(subject.formatters).to be_a(Hash)
          expect(subject.formatters).to have(1).item
          expect(subject.formatters.keys.first).to eql(format_id)
          expect(subject.formatters.values.first).to eql(format_klass)
        end
      end

      describe "::get" do
        before(:each) do
          subject.register(format_id, format_klass)
        end

        it "returns the class constant of the given formatter ID" do
          expect(subject[format_id]).to eql(format_klass)
        end

        context "when the ID has not been registered" do
          it "returns nil" do
            expect(subject[:not_there]).to be_nil
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
      expect { subject.install("my_coobook","1.2.3","http://community") }.to raise_error(AbstractFunction)
      expect { subject.use("my_coobook","1.2.3") }.to raise_error(AbstractFunction)
      expect { subject.use("my_coobook","1.2.3","http://community") }.to raise_error(AbstractFunction)
      expect { subject.upload("my_coobook","1.2.3","http://chef_server") }.to raise_error(AbstractFunction)
      expect { subject.msg("something you should know") }.to raise_error(AbstractFunction)
      expect { subject.error("whoa this is bad") }.to raise_error(AbstractFunction)
    end
  end
end
