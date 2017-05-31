require "spec_helper"

module Berkshelf
  describe Downloader do
    let(:berksfile) do
      double(Berksfile,
        lockfile: lockfile,
        dependencies: []
      )
    end

    let(:lockfile) do
      double(Lockfile,
        graph: graph
      )
    end

    let(:graph) { double(Lockfile::Graph, locks: {}) }
    let(:self_signed_crt_path) { File.join(BERKS_SPEC_DATA, "trusted_certs") }
    let(:self_signed_crt) { OpenSSL::X509::Certificate.new(IO.read("#{self_signed_crt_path}/example.crt")) }
    let(:cert_store) { OpenSSL::X509::Store.new.add_cert(self_signed_crt) }
    let(:ssl_policy) { double(SSLPolicy, store: cert_store) }

    subject { described_class.new(berksfile) }

    describe "#download" do
      skip
    end

    describe "#try_download" do
      let(:remote_cookbook) { double("remote-cookbook") }
      let(:source) do
        source = double("source")
        allow(source).to receive(:cookbook) { remote_cookbook }
        source
      end
      let(:name) { "fake" }
      let(:version) { "1.0.0" }

      it "supports the 'opscode' location type" do
        allow(source).to receive(:type) { :supermarket }
        allow(source).to receive(:options) { { ssl: {} } }
        allow(remote_cookbook).to receive(:location_type) { :opscode }
        allow(remote_cookbook).to receive(:location_path) { "http://api.opscode.com" }
        rest = double("community-rest")
        expect(CommunityREST).to receive(:new).with("http://api.opscode.com", { ssl: {} }) { rest }
        expect(rest).to receive(:download).with(name, version)
        subject.try_download(source, name, version)
      end

      it "supports the 'supermarket' location type" do
        allow(source).to receive(:type) { :supermarket }
        allow(source).to receive(:options) { { ssl: {} } }
        allow(remote_cookbook).to receive(:location_type) { :supermarket }
        allow(remote_cookbook).to receive(:location_path) { "http://api.supermarket.com" }
        rest = double("community-rest")
        expect(CommunityREST).to receive(:new).with("http://api.supermarket.com", { ssl: {} }) { rest }
        expect(rest).to receive(:download).with(name, version)
        subject.try_download(source, name, version)
      end

      context "with an artifactory source" do
        it "supports the 'opscode' location type" do
          allow(source).to receive(:type) { :artifactory }
          allow(source).to receive(:options) { { api_key: "secret", ssl: {} } }
          allow(remote_cookbook).to receive(:location_type) { :opscode }
          allow(remote_cookbook).to receive(:location_path) { "http://artifactory/" }
          rest = double("community-rest")
          expect(CommunityREST).to receive(:new).with("http://artifactory/", { ssl: {}, headers: { "X-Jfrog-Art-Api" => "secret" } }) { rest }
          expect(rest).to receive(:download).with(name, version)
          subject.try_download(source, name, version)
        end

        it "supports the 'supermarket' location type" do
          allow(source).to receive(:type) { :artifactory }
          allow(source).to receive(:options) { { api_key: "secret", ssl: {} } }
          allow(remote_cookbook).to receive(:location_type) { :supermarket }
          allow(remote_cookbook).to receive(:location_path) { "http://artifactory/" }
          rest = double("community-rest")
          expect(CommunityREST).to receive(:new).with("http://artifactory/", { ssl: {}, headers: { "X-Jfrog-Art-Api" => "secret" } }) { rest }
          expect(rest).to receive(:download).with(name, version)
          subject.try_download(source, name, version)
        end
      end

      describe "chef_server location type" do
        let(:chef_server_url) { "http://configured-chef-server/" }
        let(:ridley_client) do
          double(Ridley::Client,
            cookbook: double("cookbook", download: "fake")
          )
        end
        let(:chef_config) do
          double(Ridley::Chef::Config,
            node_name: "fake-client",
            client_key: "client-key",
            chef_server_url: chef_server_url,
            validation_client_name: "validator",
            validation_key: "validator.pem",
            artifactory_api_key: "secret",
            cookbook_copyright: "user",
            cookbook_email: "user@example.com",
            cookbook_license: "apachev2",
            trusted_certs_dir: self_signed_crt_path,
            knife: {
              chef_guard: false,
            }
          )
        end

        let(:berkshelf_config) do
          double(Config,
            ssl:  double(verify: true),
            chef: chef_config
          )
        end

        before do
          allow(Berkshelf).to receive(:config).and_return(berkshelf_config)
          allow(subject).to receive(:ssl_policy).and_return(ssl_policy)
          allow(remote_cookbook).to receive(:location_type) { :chef_server }
          allow(remote_cookbook).to receive(:location_path) { chef_server_url }
          allow(source).to receive(:options) { { read_timeout: 30, open_timeout: 3, ssl: { verify: true, cert_store: cert_store } } }
        end

        it "uses the berkshelf config and provides a custom cert_store" do
          credentials = {
            server_url: chef_server_url,
            client_name: chef_config.node_name,
            client_key: chef_config.client_key,
            ssl: {
              verify: berkshelf_config.ssl.verify,
              cert_store: cert_store,
            },
          }
          expect(Ridley).to receive(:open).with(credentials) { ridley_client }
          subject.try_download(source, name, version)
        end

        context "with a source option for client_name" do
          before do
            allow(source).to receive(:options) { { client_name: "other-client", read_timeout: 30, open_timeout: 3, ssl: { verify: true, cert_store: cert_store } } }
          end
          it "uses the override" do
            credentials = {
              server_url: chef_server_url,
              client_name: "other-client",
              client_key: chef_config.client_key,
              ssl: {
                verify: berkshelf_config.ssl.verify,
                cert_store: cert_store,
              },
            }
            expect(Ridley).to receive(:open).with(credentials) { ridley_client }
            subject.try_download(source, name, version)
          end
        end

        context "with a source option for client_key" do
          before do
            allow(source).to receive(:options) { { client_key: "other-key", read_timeout: 30, open_timeout: 3, ssl: { verify: true, cert_store: cert_store } } }
          end
          it "uses the override" do
            credentials = {
              server_url: chef_server_url,
              client_name: chef_config.node_name,
              client_key: "other-key",
              ssl: {
                verify: berkshelf_config.ssl.verify,
                cert_store: cert_store,
              },
            }
            expect(Ridley).to receive(:open).with(credentials) { ridley_client }
            subject.try_download(source, name, version)
          end
        end
      end

      it "supports the 'file_store' location type" do
        skip
      end
    end
  end
end
