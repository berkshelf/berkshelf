require 'spec_helper'

describe Berkshelf::CachedLocation do
  let(:complacent_constraint) { double('comp-vconstraint', satisfies?: true) }
  let(:path) { fixtures_path.join('cookbooks', 'example_cookbook').to_s }
  let(:cached_cookbook) { double('example_cookbook', path: path, metadata: true)}

  subject {Berkshelf::CachedLocation.new('nginx', complacent_constraint, cached_cookbook)}

  describe '.new' do
    it 'assigns cached_cookbook\'s path to @path' do
      expect(subject.path).to eq(path)
    end

    it 'sets the metadata option' do
      expect(subject.metadata?).to be_true
    end
  end
end
