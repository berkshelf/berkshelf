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
    before { subject.stub(:path).and_return('/foo/bar') }

    it 'includes the path' do
      expect(subject.to_s).to eq('#<Berkshelf::PathLocation /foo/bar>')
    end
  end

  describe '#inspect' do
    before do
      subject.stub(:path).and_return('/foo/bar')
      subject.stub(:name).and_return('nginx')
      subject.stub(:version_constraint).and_return('~> 1.0.0')
    end

    it 'includes the path' do
      expect(subject.inspect).to eq('#<Berkshelf::PathLocation /foo/bar, name: nginx, version_constraint: ~> 1.0.0>')
    end
  end

  describe '#info' do
    context 'for a remote path' do
      subject { Berkshelf::PathLocation.new('nginx', complacent_constraint, path: path) }

      it 'includes the path information' do
        expect(subject.info).to match(/path\:.+example_cookbook/)
      end
    end

    context 'for a store path' do
      subject { Berkshelf::PathLocation.new('nginx', complacent_constraint, path: File.join(Berkshelf.berkshelf_path, 'cookbooks/example_cookbook')) }

      it 'does not include the path information' do
        expect(subject.info).to_not match(/path\:.+/)
      end
    end
  end
end
