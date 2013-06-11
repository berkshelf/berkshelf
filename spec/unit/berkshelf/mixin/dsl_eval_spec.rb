require 'spec_helper'

describe Berkshelf::Mixin::DSLEval do
  let(:klass) do
    klass = Class.new
    klass.send(:include, described_class)
    klass
  end

  describe "ClassMethods" do
    describe "::clean_room" do
      subject { klass.clean_room }

      it "returns an anonymous class inheriting from DSLEval::CleanRoom" do
        expect(subject.superclass).to eql(described_class::CleanRoom)
      end
    end

    describe "::expose_method" do
      subject { klass }

      it "adds a method to the exposed methods" do
        klass.expose_method(:something)
        expect(subject.exposed_methods).to have(1).item
      end
    end

    describe "::exposed_methods" do
      it "returns an array" do
        expect(klass.exposed_methods).to be_a(Array)
      end
    end
  end

  describe "#dsl_eval" do
    subject do
      klass.new.dsl_eval { }
    end

    it "returns an instance of the including class" do
      expect(subject).to be_a(klass)
    end
  end

  describe "#dsl_eval_file" do
    let(:filepath) { tmp_path.join('somefile') }
    before { FileUtils.touch(filepath) }

    subject { klass.new.dsl_eval_file(filepath) }

    it "returns an instance of the including class" do
      expect(subject).to be_a(klass)
    end
  end
end
