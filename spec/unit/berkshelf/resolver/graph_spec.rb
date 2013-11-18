require 'spec_helper'

describe Berkshelf::Resolver::Graph do
  let(:berkshelf) { double(name: 'berkshelf', version: '1.0.0', dependencies: { 'ridley' => '1.0.0' }) }
  let(:ridley)    { double(name: 'ridley', version: '1.0.0', dependencies: {}) }
  let(:sources)   { [ double('source_1', universe: [berkshelf, ridley]) ] }

  describe '#populate' do
    it 'adds each dependency to the graph' do
      subject.populate(sources)
      expect(subject.artifacts).to have(2).items
    end

    it 'adds the dependencies of each dependency to the graph' do
      subject.populate(sources)
      expect(subject.artifacts('berkshelf', '1.0.0').dependencies).to have(1).item
    end
  end

  describe '#universe' do
    it 'returns an array of RemoteCookbook objects' do
      result = subject.universe(sources)
      expect(result).to be_an(Array)
      expect(result[0]).to eq(berkshelf)
      expect(result[1]).to eq(ridley)
    end

    it 'contains the entire universe' do
      expect(subject.universe(sources)).to have(2).items
    end
  end
end
