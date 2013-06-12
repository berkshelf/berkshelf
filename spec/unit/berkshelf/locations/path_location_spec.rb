require 'spec_helper'

describe Berkshelf::PathLocation do
  let(:complacent_constraint) { double('comp-vconstraint', satisfies?: true) }
  let(:path) { fixtures_path.join('cookbooks', 'example_cookbook').to_s }

  describe '.new' do
    it 'assigns the value of :path to @path' do
      location = Berkshelf::PathLocation.new('nginx', complacent_constraint, path: path)
      expect(location.path).to eq(path)
    end
  end



  subject { Berkshelf::PathLocation.new('nginx', complacent_constraint, path: path) }

  describe '#to_s' do
    context 'for a remote path' do
      subject { Berkshelf::PathLocation.new('nginx', complacent_constraint, path: path) }

      it 'includes the path information' do
        expect(subject.to_s).to match(/path\:.+example_cookbook/)
      end
    end

    context 'for a store path' do
      subject { Berkshelf::PathLocation.new('nginx', complacent_constraint, path: File.join(Berkshelf.berkshelf_path, 'cookbooks/example_cookbook')) }

      it 'does not include the path information' do
        expect(subject.to_s).to_not match(/path\:.+/)
      end
    end
  end
end
