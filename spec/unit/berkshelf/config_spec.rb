require 'spec_helper'

describe Berkshelf::Config do
  #
  # Class Methods
  # -------------------------

  # Berkshelf::Config.file
  describe '.file' do
    context 'when the file does not exist' do
      before { File.stub(:exists?).and_return(false) }

      it 'is nil' do
        expect(Berkshelf::Config.file).to be_nil
      end
    end
  end

  # Berkshelf::Config.instance
  describe '.instance' do
    it 'should be a Berkshelf::Config' do
      expect(Berkshelf::Config.instance).to be_an_instance_of(Berkshelf::Config)
    end
  end

  # Berkshelf::Config.path
  describe '.path' do
    it 'is a string' do
      expect(Berkshelf::Config.path).to be_a(String)
    end

    it "points to a location within ENV['BERKSHELF_PATH']" do
      ENV.stub(:[]).with('BERKSHELF_PATH').and_return('/tmp')
      expect(Berkshelf::Config.path).to eq('/tmp/config.json')
    end
  end
end
