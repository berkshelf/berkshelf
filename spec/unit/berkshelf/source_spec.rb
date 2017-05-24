require "spec_helper"

module Berkshelf
  describe Source do
    let(:berksfile) { double("Berksfile", filepath: "/test/Berksfile") }
    let(:arguments) { [] }
    let(:config) { Config.new }
    subject(:instance) { described_class.new(berksfile, *arguments) }
    before do
      allow(Berkshelf::Config).to receive(:instance).and_return(config)
    end

    describe "#type" do
      subject { instance.type }

      context "with a string argument" do
        let(:arguments) { ["https://example.com"] }
        it { is_expected.to eq :supermarket }
      end

      context "with a string argument and options" do
        let(:arguments) { ["https://example.com", { key: "value" }] }
        it { is_expected.to eq :supermarket }
      end

      context "with a symbol argument" do
        let(:arguments) { [:chef_server] }
        it { is_expected.to eq :chef_server }
      end

      context "with a symbol argument and options" do
        let(:arguments) { [:chef_server, { key: "value" }] }
        it { is_expected.to eq :chef_server }
      end

      context "with a hash argument" do
        let(:arguments) { [{ artifactory: "https://example.com/api/chef/chef-virtual" }] }
        it { is_expected.to eq :artifactory }
      end

      context "with a hash argument and connected options" do
        let(:arguments) { [{ artifactory: "https://example.com/api/chef/chef-virtual", key: "value" }] }
        it { is_expected.to eq :artifactory }
      end

      context "with a hash argument and disconnected options" do
        let(:arguments) { [{ artifactory: "https://example.com/api/chef/chef-virtual" }, { key: "value" }] }
        it { is_expected.to eq :artifactory }
      end
    end

    describe "#uri" do
      subject { instance.uri.to_s }

      context "with a string argument" do
        let(:arguments) { ["https://example.com"] }
        it { is_expected.to eq "https://example.com" }
      end

      context "with a string argument and options" do
        let(:arguments) { ["https://example.com", { key: "value" }] }
        it { is_expected.to eq "https://example.com" }
      end

      context "with a symbol argument" do
        let(:arguments) { [:chef_server] }
        before { config.chef.chef_server_url = "https://chefserver/" }
        it { is_expected.to eq "https://chefserver/" }
      end

      context "with a symbol argument and options" do
        let(:arguments) { [:chef_server, { key: "value" }] }
        before { config.chef.chef_server_url = "https://chefserver/" }
        it { is_expected.to eq "https://chefserver/" }
      end

      context "with a hash argument" do
        let(:arguments) { [{ artifactory: "https://example.com/api/chef/chef-virtual" }] }
        it { is_expected.to eq "https://example.com/api/chef/chef-virtual" }
      end

      context "with a hash argument and connected options" do
        let(:arguments) { [{ artifactory: "https://example.com/api/chef/chef-virtual", key: "value" }] }
        it { is_expected.to eq "https://example.com/api/chef/chef-virtual" }
      end

      context "with a hash argument and disconnected options" do
        let(:arguments) { [{ artifactory: "https://example.com/api/chef/chef-virtual" }, { key: "value" }] }
        it { is_expected.to eq "https://example.com/api/chef/chef-virtual" }
      end

      context "with an invalid URI" do
        let(:arguments) { ["ftp://example.com"] }
        it { expect { subject }.to raise_error InvalidSourceURI }
      end

      context "with a chef_repo source" do
        let(:arguments) { [{ chef_repo: "." }] }
        it { is_expected.to eq(windows? ? "file://C/test" : "file:///test") }
      end
    end

    describe "#options" do
      subject { instance.options }

      context "with a string argument" do
        let(:arguments) { ["https://example.com"] }

        it { is_expected.to be_a(Hash) }
        # Check all baseline values.
        its([:timeout]) { is_expected.to eq 30 }
        its([:open_timeout]) { is_expected.to eq 3 }
        its([:ssl, :verify]) { is_expected.to be true }
        its([:ssl, :ca_file]) { is_expected.to be_nil }
        its([:ssl, :ca_path]) { is_expected.to be_nil }
        its([:ssl, :client_cert]) { is_expected.to be_nil }
        its([:ssl, :client_key]) { is_expected.to be_nil }
        its([:ssl, :cert_store]) { is_expected.to be_a(OpenSSL::X509::Store) }
      end

      context "with a string argument and options" do
        let(:arguments) { ["https://example.com", { key: "value" }] }
        its([:key]) { is_expected.to eq "value" }
      end

      context "with a symbol argument" do
        let(:arguments) { [:chef_server] }
        it { is_expected.to be_a(Hash) }
      end

      context "with a symbol argument and options" do
        let(:arguments) { [:chef_server, { key: "value" }] }
        its([:key]) { is_expected.to eq "value" }
      end

      context "with a hash argument" do
        let(:arguments) { [{ artifactory: "https://example.com/api/chef/chef-virtual" }] }
        it { is_expected.to be_a(Hash) }
      end

      context "with a hash argument and connected options" do
        let(:arguments) { [{ artifactory: "https://example.com/api/chef/chef-virtual", key: "value" }] }
        its([:key]) { is_expected.to eq "value" }
      end

      context "with a hash argument and disconnected options" do
        let(:arguments) { [{ artifactory: "https://example.com/api/chef/chef-virtual" }, { key: "value" }] }
        its([:key]) { is_expected.to eq "value" }
      end

      context "with an artifactory source and the API key in the Chef config" do
        let(:arguments) { [{ artifactory: "https://example.com/api/chef/chef-virtual" }] }
        before { config.chef.artifactory_api_key = "secret" }
        its([:api_key]) { is_expected.to eq "secret" }
      end

      context "with a chef_repo source" do
        let(:arguments) { [{ chef_repo: "." }] }
        its([:path]) { is_expected.to eq(windows? ? "C:/test" : "/test") }
      end
    end

    describe "#==" do
      it "is the same if the uri matches" do
        first = described_class.new(berksfile, "http://localhost:8080")
        other = described_class.new(berksfile, "http://localhost:8080")

        expect(first).to eq(other)
      end

      it "is not the same if the uri is different" do
        first = described_class.new(berksfile, "http://localhost:8089")
        other = described_class.new(berksfile, "http://localhost:8080")

        expect(first).to_not eq(other)
      end
    end

    describe ".default?" do
      it "returns true when the source is the default" do
        instance = described_class.new(berksfile, Berksfile::DEFAULT_API_URL)
        expect(instance).to be_default
      end

      it "returns true when the scheme is different" do
        instance = described_class.new(berksfile, "http://supermarket.chef.io")
        expect(instance).to be_default
      end

      it "returns false when the source is not the default" do
        instance = described_class.new(berksfile, "http://localhost:8080")
        expect(instance).to_not be_default
      end
    end

    describe "#search" do
      let (:cookbooks) do
        [
        APIClient::RemoteCookbook.new("cb1", "1.0.8"),
        APIClient::RemoteCookbook.new("cb1", "1.0.22"),
      ] end

      before do
        allow_any_instance_of(APIClient::Connection).to receive(:universe).and_return(cookbooks)
      end

      it "returns the latest version" do
        instance = described_class.new(berksfile, Berksfile::DEFAULT_API_URL)
        expect(instance.search("cb1")).to eq [cookbooks[1]]
      end
    end
  end
end
