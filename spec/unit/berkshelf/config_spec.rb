require 'spec_helper'

describe Berkshelf::Config do
  describe "ClassMethods" do
    describe '::file' do
      context 'when the file does not exist' do
        before { File.stub(:exists?).and_return(false) }

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
        File.stub(:exists?).and_return(false)
      end

      after do
        Berkshelf::Config.instance_variable_set(:@path, nil)
      end

      context "when ENV['BERKSHELF_CONFIG'] is used" do
        before do
          ENV.stub(:[]).with('BERKSHELF_CONFIG').and_return('/tmp/config.json')
          File.stub(:exists?).with('/tmp/config.json').and_return(true)
        end

        it "points to a location within it" do
          expect(Berkshelf::Config.path).to eq('/tmp/config.json')
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

  describe "#chef_servers" do
    it "returns a hash containing a default entry" do
      expect(subject.chef_servers).to be_a(Hash)
      expect(subject.chef_servers).to have(1).item
      expect(subject.chef_servers).to have_key(:default)
    end
  end

  describe "#chef_server" do
    it "returns the entry for the given name" do
      expect(subject.chef_server(:default)).to be_a(Hash)
    end

    context "when the entry does not exist" do
      it "returns nil" do
        expect(subject.chef_server(:something_not_there)).to be_nil
      end
    end
  end

  describe "#chef" do
    it "returns the default chef server entry" do
      expect(subject.chef).to eq(subject.chef_server(:default))
    end
  end

  context "loading an old style config" do
    it "coerces the chef keys into the default chef server" do
      json   = JSON.generate(chef: {
        chef_server_url: "val1",
        validation_client_name: "val2",
        validation_key_path: "val3",
        client_key: "val4",
        node_name: "val5"
      })
      config         = described_class.from_json(json)
      default_server = config.chef_servers[:default]

      expect(default_server[:chef_server_url]).to eq("val1")
      expect(default_server[:validation_client_name]).to eq("val2")
      expect(default_server[:validation_key_path]).to eq("val3")
      expect(default_server[:client_key]).to eq("val4")
      expect(default_server[:node_name]).to eq("val5")
    end
  end
end
