require 'spec_helper'

describe Berkshelf::Lockfile do
  describe '.from_file' do
    let(:content) { File.read(fixtures_path.join('lockfiles/default.lock')) }

    subject { Berkshelf::Lockfile.from_file('Berksfile.lock') }

    before do
      content
      File.stub(:read).and_return(content)
    end

    it 'has the correct sha' do
      expect(subject.sha).to eq('6b76225554cc1f7c0aea0f8b3f10c6743aeba67e')
    end

    it 'has the correct sources' do
      expect(subject).to have_source 'build-essential'
      expect(subject).to have_source 'chef-client'
    end

    context 'when the file does not exist' do
      before do
        File.stub(:read).and_raise(Errno::ENOENT)
      end

      it 'raises a Berkshelf::LockfileNotFound' do
        expect {
          Berkshelf::Lockfile.from_file('Berksfile.lock')
        }.to raise_error(Berkshelf::LockfileNotFound)
      end
    end

    describe '#save' do
      before { Berkshelf::Lockfile.send(:public, :save) }
      let(:file) { double('file') }

      before(:each) do
        File.stub(:open).with('Berksfile.lock', 'w')
      end

      it 'saves itself to a file on disk' do
        File.should_receive(:open).with('Berksfile.lock', 'w').and_yield(file)
        file.should_receive(:write).once
        subject.save
      end
    end

    describe '#update' do
      it 'resets the sources' do
        subject.should_receive(:reset_sources!).once
        subject.update([])
      end

      it 'updates the sha' do
        expect {
          subject.update([])
        }.to change { subject.sha }
      end

      it 'appends each of the sources' do
        source = double('source')
        subject.should_receive(:append).with(source).once
        subject.update([source])
      end

      it 'saves the file' do
        subject.should_receive(:save).once
        subject.update([])
      end
    end

    describe '#add' do
      let(:source) { double('source', name: 'build-essential') }

      it 'adds the new source to the @sources instance variable' do
        subject.add(source)
        expect(subject).to have_source(source)
      end

      it 'does not add duplicate sources' do
        5.times { subject.add(source) }
        expect(subject).to have_source(source)
      end
    end

    describe '#remove' do
      let(:source) { double('source', name: 'build-essential') }

      before do
        subject.add(source)
      end

      it 'removes the source' do
        subject.remove(source)
        expect(subject).to_not have_source(source)
      end

      it 'raises an except if the source does not exist' do
        expect {
          subject.remove(nil)
        }.to raise_error Berkshelf::CookbookNotFound
      end
    end

    describe '#to_hash' do
      let(:hash) { subject.to_hash }

      it 'has the `:sha` key' do
        expect(hash).to have_key(:sha)
      end

      it 'has the `:sources` key' do
        expect(hash).to have_key(:sources)
      end
    end

    describe '#to_json' do
      it 'dumps the #to_hash to MultiJson' do
        MultiJson.should_receive(:dump).with(subject.to_hash, pretty: true)
        subject.to_json
      end
    end
  end
end
