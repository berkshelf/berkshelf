require 'spec_helper'

describe Berkshelf::Formatters::JSON do
  before do
    Berkshelf.set_format(:null)
    $stdout.stub(:puts) # We use puts for JSON instead of the UI
  end

  Berkshelf::Formatters::AbstractFormatter.instance_methods.each do |meth|
    it "does not raise an error for :#{meth}" do
      expect {
        subject.send(meth)
      }.to_not raise_error(Berkshelf::AbstractFunction)
    end
  end

  describe '#to_s' do
    it 'includes the class name' do
      expect(subject.to_s).to eq("#<#{described_class}>")
    end
  end

  describe '#inspect' do
    it 'is the same as #to_s' do
      expect(subject.inspect).to eq(subject.to_s)
    end
  end
end
