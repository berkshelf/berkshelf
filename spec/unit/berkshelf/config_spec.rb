require 'spec_helper'

describe Berkshelf::Config do
  describe '::file' do
    context 'when the file does not exist' do
      before { allow(File).to receive(:exists?).and_return(false) }

      it 'is nil' do
        expect(Berkshelf::Config.file).to be_nil
      end
    end
  end

  describe '::instance' do
    it 'should be a Berkshelf::Config' do
      expect(Berkshelf::Config.instance).to be_an_instance_of(Berkshelf::Config)
    end
  end

  describe '::path' do
    it 'is a string' do
      expect(Berkshelf::Config.path).to be_a(String)
    end

    before do
      allow(File).to receive(:exists?).and_return(false)
    end

    after do
      Berkshelf::Config.instance_variable_set(:@path, nil)
    end

    context "when ENV['BERKSHELF_CONFIG'] is used" do
      before do
        allow(ENV).to receive(:[]).with('BERKSHELF_CONFIG').and_return('/tmp/config.json')
        allow(File).to receive(:exists?).with('/tmp/config.json').and_return(true)
      end

      it "points to a location within it" do
        expect(Berkshelf::Config.path).to match(%r{/tmp/config.json})
      end
    end
  end

  describe "::set_path" do
    subject(:set_path) { described_class.set_path("/tmp/other_path.json") }

    it "sets the #instance to nil" do
      set_path
      expect(described_class.instance_variable_get(:@instance)).to be_nil
    end
  end
end
