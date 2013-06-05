require 'spec_helper'

describe Berkshelf::Lockfile do
  let!(:content) { File.read(fixtures_path.join('lockfiles/default.lock')) }
  let(:berksfile) { Berkshelf::Berksfile.new('Berksfile') }

  before do
    File.stub(:read).and_return(content)
  end

  describe '.initialize' do
    it 'does not throw an exception' do
      expect {
        Berkshelf::Lockfile.new(berksfile)
      }.to_not raise_error
    end

    it 'has the correct sha' do
      expect(subject.sha).to eq('6b76225554cc1f7c0aea0f8b3f10c6743aeba67e')
    end

    it 'has the correct dependencies' do
      expect(subject).to have_dependency 'build-essential'
      expect(subject).to have_dependency 'chef-client'
    end
  end

  subject { Berkshelf::Lockfile.new(berksfile) }

  describe '#reset_sha!' do
    it 'sets the sha to nil' do
      expect { subject.reset_sha! }.to change { subject.sha }.to nil
    end
  end

  describe '#dependencies' do
    it 'returns an array' do
      expect(subject.dependencies).to be_a(Array)
    end
  end

  describe '#find' do
    it 'returns a matching cookbook' do
      expect(subject.find('build-essential').name).to eq 'build-essential'
    end

    it 'returns nil for a missing cookbook' do
      expect(subject.find('foo')).to be_nil
    end
  end

  describe '#has_dependency?' do
    it 'returns true if a matching cookbook is found' do
      expect(subject.has_dependency?('build-essential')).to be_true
    end

    it 'returns false if no matching cookbook is found' do
      expect(subject.has_dependency?('foo')).to be_false
    end
  end

  describe '#update' do
    it 'resets the dependencies' do
      subject.should_receive(:reset_dependencies!).once
      subject.update([])
    end

    it 'updates the sha' do
      expect {
        subject.update([])
      }.to change { subject.sha }
    end

    it 'appends each of the dependencies' do
      dependency = double('dependency')
      subject.should_receive(:append).with(dependency).once
      subject.update([dependency])
    end

    it 'saves the file' do
      subject.should_receive(:save).once
      subject.update([])
    end
  end

  describe '#add' do
    let(:dependency) { double('dependency', name: 'build-essential') }

    it 'adds the new dependency to the @dependencies instance variable' do
      subject.add(dependency)
      expect(subject).to have_dependency(dependency)
    end

    it 'does not add duplicate dependencies' do
      5.times { subject.add(dependency) }
      expect(subject).to have_dependency(dependency)
    end
  end

  describe '#remove' do
    let(:dependency) { double('dependency', name: 'build-essential') }

    before do
      subject.add(dependency)
    end

    it 'removes the dependency' do
      subject.remove(dependency)
      expect(subject).to_not have_dependency(dependency)
    end

    it 'raises an except if the dependency does not exist' do
      expect {
        subject.remove(nil)
      }.to raise_error Berkshelf::CookbookNotFound
    end
  end

  describe '#to_s' do
    before { subject.stub(:filepath).and_return('/foo/bar.lock') }

    it 'returns a pretty-formatted string' do
      expect(subject.to_s).to eq("#<#{described_class} #{subject.filepath}>")
    end
  end

  describe '#inspect' do
    before { subject.stub(:filepath).and_return('/foo/bar.lock') }

    it 'returns a pretty-formatted, detailed string' do
      expect(subject.inspect).to eq("#<#{described_class} #{subject.filepath}, dependencies: [#{subject.dependencies.map(&:name_and_version).join(', ')}]>")
    end
  end

  describe '#to_hash' do
    let(:hash) { subject.to_hash }

    it 'has the `:sha` key' do
      expect(hash).to have_key(:sha)
    end

    it 'has the `:dependencies` key' do
      expect(hash).to have_key(:dependencies)
    end
  end

  describe '#to_json' do
    it 'dumps the #to_hash to JSON' do
      JSON.should_receive(:pretty_generate).with(subject.to_hash, {})
      subject.to_json
    end
  end

  describe '#save' do
    before { Berkshelf::Lockfile.send(:public, :save) }
    let(:file) { double('file') }

    before(:each) do
      File.stub(:open).with('Berksfile.lock', 'w')
    end

    it 'saves itself to a file on disk' do
      File.should_receive(:open).with(/(.+)\/Berksfile\.lock/, 'w').and_yield(file)
      file.should_receive(:write).once
      subject.save
    end
  end

  describe '#reset_dependencies!' do
    before { Berkshelf::Lockfile.send(:public, :reset_dependencies!) }

    it 'sets the dependencies to an empty hash' do
      expect {
        subject.reset_dependencies!
      }.to change { subject.dependencies }.to([])
    end
  end

  describe '#cookbook_name' do
    before { Berkshelf::Lockfile.send(:public, :cookbook_name) }

    it 'accepts a cookbook dependency' do
      dependency = double('dependency', name: 'build-essential', is_a?: true)
      expect(subject.cookbook_name(dependency)).to eq 'build-essential'
    end

    it 'accepts a string' do
      expect(subject.cookbook_name('build-essential')).to eq 'build-essential'
    end
  end
end
