require 'spec_helper'

describe Berkshelf::Lockfile do
  describe ".from_file" do
    let(:filename) { 'Berksfile.lock' }
    let(:lockfile) { Berkshelf::Lockfile.from_file(filename) }
    let(:content) { File.read(fixtures_path.join('lockfiles/default.lock')) }

    subject { lockfile }

    before do
      content
      File.stub(:read).and_return(content)
    end

    it "has the correct sha" do
      expect(lockfile.sha).to eq('6b76225554cc1f7c0aea0f8b3f10c6743aeba67e')
    end

    it "has the correct sources" do
      expect(lockfile.sources.map(&:name)).to eq(['build-essential', 'chef-client'])
    end

    context "when the file does not exist" do
      before do
        ::File.stub(:read).and_raise(::Errno::ENOENT)
      end

      it "raises a Berkshelf::LockfileNotFound" do
        expect {
          ::Berkshelf::Lockfile.from_file(filename)
        }.to raise_error(::Berkshelf::LockfileNotFound)
      end
    end

    describe "#save" do
      before(:each) do
        subject.stub(:filepath) { tmp_path.join('speclockfile.json')}
      end

      it "saves itself to a file on disk" do
        subject.save

        File.exist?(subject.filepath).should be_true
      end
    end

    describe "#update" do
      it "raises a Berkshelf::ArgumentError if one of the sources is not valid" do
        expect {
          lockfile.update(['foo'])
        }.to raise_error(::Berkshelf::ArgumentError)
      end

      it "sets the @sources instance variable" do
        source = double('source')
        source.stub(:is_a?).with(any_args()).and_return(true)

        lockfile.update([source])
        expect(lockfile.sources).to eq([source])
      end
    end

    describe "#append" do
      it "raises a Berkshelf::ArgumentError if one of the sources is not valid" do
        expect {
          lockfile.append('foo')
        }.to raise_error(::Berkshelf::ArgumentError)
      end

      it "adds the new source to the @sources instance variable" do
        source = double(name: 'source')
        source.stub(:is_a?).with(any_args()).and_return(true)

        lockfile.append(source)
        expect(lockfile.sources.map(&:name)).to eq(['build-essential', 'chef-client', 'source'])
      end

      it "does not add duplicate sources" do
        source = double(name: 'source')
        source.stub(:is_a?).with(any_args()).and_return(true)

        5.times do
          lockfile.append(source)
        end

        expect(lockfile.sources.map(&:name)).to eq(['build-essential', 'chef-client', 'source'])
      end
    end

    describe "#to_hash" do
      let(:hash) { lockfile.to_hash }

      it "has the :sha key" do
        expect(hash).to have_key(:sha)
      end

      it "has the :sources key" do
        expect(hash).to have_key(:sources)
      end
    end

    describe "#to_json" do
      it "dumps the #to_hash to MultiJson" do
        MultiJson.should_receive(:dump).with(lockfile.to_hash, pretty: true)
        lockfile.to_json
      end
    end
  end
end
