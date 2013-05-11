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

  describe '#download' do
    it 'returns an instance of CachedCookbook' do
      expect(subject.download(tmp_path)).to be_a(Berkshelf::CachedCookbook)
    end

    it 'sets the downloaded status to true' do
      subject.download(tmp_path)
      expect(subject).to be_downloaded
    end

    context 'given a path that does not exist' do
      subject { Berkshelf::PathLocation.new('doesnot_exist', complacent_constraint, path: tmp_path.join('doesntexist_noway')) }

      it 'raises a CookbookNotFound error' do
        expect {
          subject.download(tmp_path)
        }.to raise_error(Berkshelf::CookbookNotFound)
      end
    end

    context 'given a path that does not contain a cookbook' do
      subject { Berkshelf::PathLocation.new('doesnot_exist', complacent_constraint, path: fixtures_path) }

      it 'raises a CookbookNotFound error' do
        expect {
          subject.download(tmp_path)
        }.to raise_error(Berkshelf::CookbookNotFound)
      end
    end

    context 'given the content at path does not satisfy the version constraint' do
      subject { Berkshelf::PathLocation.new('nginx', double('constraint', satisfies?: false), path: path) }

      it 'raises a CookbookValidationFailure error' do
        expect {
          subject.download(double('path'))
        }.to raise_error(Berkshelf::CookbookValidationFailure)
      end
    end
  end

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
