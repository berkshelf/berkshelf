require "spec_helper"

describe Berkshelf::Config do
  describe "::file" do
    context "when the file does not exist" do
      before { allow(File).to receive(:exists?).and_return(false) }

      it "is nil" do
        expect(Berkshelf::Config.file).to be_nil
      end
    end
  end

  describe "::instance" do
    it "should be a Berkshelf::Config" do
      expect(Berkshelf::Config.instance).to be_an_instance_of(Berkshelf::Config)
    end

    context "attributes" do
      it "should have a default API timeout" do
        expect(Berkshelf::Config.instance.api.timeout).to eq("30")
      end
    end

    context "a Chef config to read defaults from" do
      let(:chef_config) do
        double(
          Ridley::Chef::Config,
          chef_server_url: "https://chef.example.com",
          validation_client_name: "validator",
          validation_key: "validator.pem",
          client_key: "client-key",
          node_name: "fake-client",
          trusted_certs_dir: "/tmp/fakecerts",
          artifactory_api_key: "secret",
          cookbook_copyright: "user",
          cookbook_email: "user@example.com",
          cookbook_license: "apachev2"
        )
      end

      before do
        allow(Berkshelf).to receive(:chef_config).and_return(chef_config)
      end

      {
        chef_server_url: "https://chef.example.com",
        validation_client_name: "validator",
        validation_key_path: "validator.pem",
        client_key: "client-key",
        node_name: "fake-client",
        trusted_certs_dir: "/tmp/fakecerts",
        artifactory_api_key: "secret",
      }.each do |attr, default|
        it "should have a default chef.#{attr}" do
          expect(Berkshelf::Config.instance.chef.send(attr)).to eq(default)
        end
      end

      {
        copyright: "user",
        email: "user@example.com",
        license: "apachev2",
      }.each do |attr, default|
        it "should have a default cookbook.#{attr}" do
          expect(Berkshelf::Config.instance.cookbook.send(attr)).to eq(default)
        end
      end
    end
  end

  describe "::path" do
    it "is a string" do
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
        allow(ENV).to receive(:[]).with("BERKSHELF_CONFIG").and_return("/tmp/config.json")
        allow(File).to receive(:exists?).with("/tmp/config.json").and_return(true)
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
