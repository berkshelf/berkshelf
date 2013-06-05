require 'spec_helper'

describe Berkshelf::Chef::Config do
  describe '#to_s' do
    it 'includes the correct class name' do
      expect(subject.to_s).to eq('#<Berkshelf::Chef::Config (new)>')
    end
  end

  describe '#inspect' do
    before { subject.stub(:configuration).and_return({foo: 'bar'}) }
    it 'includes the configuration hash' do
      expect(subject.inspect).to eq('#<Berkshelf::Chef::Config (new) configuration: {:foo=>"bar"}>')
    end
  end
end
