require 'spec_helper'

describe Berkshelf::CleanRoom do
  let(:scope) { Module.new }
  let(:instance) { double('instance') }
  let(:contents) { double('contents') }

  subject { described_class.new(scope, instance, contents) }

  describe '.initialize' do
    before do
      scope.stub(:public_instance_methods).and_return([:foo, :bar])
    end

    it 'sets the instance variable' do
      ivar = subject.instance_variable_get(:@instance)
      expect(ivar).to eq(instance)
    end

    it 'defines a method for every module method' do
      scope.should_receive(:public_instance_methods).once

      expect(subject).to respond_to(:foo)
      expect(subject).to respond_to(:bar)

      subject
    end
  end

  describe '#result' do
    it 'returns the instance' do
      expect(subject.result).to eq(instance)
    end
  end
end
