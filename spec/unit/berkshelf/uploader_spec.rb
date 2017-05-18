require "spec_helper"

module Berkshelf
  describe Uploader do
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

    subject { Uploader.new(berksfile) }

    describe "#initialize" do
      it "saves the berksfile" do
        instance = Uploader.new(berksfile)
        expect(instance.berksfile).to be(berksfile)
      end

      it "saves the lockfile" do
        instance = Uploader.new(berksfile)
        expect(instance.lockfile).to be(lockfile)
      end

      it "saves the options" do
        instance = Uploader.new(berksfile, force: true, validate: false)
        options = instance.options
        expect(options[:force]).to be(true)
        expect(options[:validate]).to be(false)
      end

      it "saves the names" do
        instance = Uploader.new(berksfile, "cookbook_1", "cookbook_2")
        expect(instance.names).to eq(%w{cookbook_1 cookbook_2})
      end
    end

    describe "#run" do
      let(:options) { Hash.new }

      let(:chef_config) do
        double(Ridley::Chef::Config,
          node_name: "fake-client",
          client_key: "client-key",
          chef_server_url: "http://configured-chef-server/",
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

      let(:default_ridley_options) do
        {
          client_name: "fake-client",
          client_key: "client-key",
          ssl: {
            verify: true,
          },
        }
      end

      before do
        allow(Berkshelf).to receive(:config).and_return(berkshelf_config)
        allow(Berkshelf).to receive(:ssl_policy).and_return(ssl_policy)
      end

      context "when there is no value for :chef_server_url" do
        before { allow(chef_config).to receive_messages(chef_server_url: nil) }
        let(:message) { "Missing required attribute in your Berkshelf configuration: chef.server_url" }

        it "raises an error" do
          expect { subject.run }.to raise_error(Berkshelf::ChefConnectionError, message)
        end
      end

      context "when there is no value for :client_name" do
        before { allow(chef_config).to receive_messages(node_name: nil) }
        let(:message) { "Missing required attribute in your Berkshelf configuration: chef.node_name" }

        it "raises an error" do
          expect { subject.run }.to raise_error(Berkshelf::ChefConnectionError, message)
        end
      end

      context "when there is no value for :client_key" do
        before { allow(chef_config).to receive_messages(client_key: nil) }
        let(:message) { "Missing required attribute in your Berkshelf configuration: chef.client_key" }

        it "raises an error" do
          expect do
            subject.run
          end.to raise_error(Berkshelf::ChefConnectionError, message)
        end
      end

      context "when no options are given" do
        let(:ridley_options) do
          { server_url: "http://configured-chef-server/" }.merge(default_ridley_options)
        end

        it "uses the Berkshelf::Config options" do
          expect(Ridley).to receive(:open).with(
            server_url:  chef_config.chef_server_url,
            client_name: chef_config.node_name,
            client_key:  chef_config.client_key,
            ssl: {
              verify: berkshelf_config.ssl.verify,
              cert_store: cert_store,
            }
          )
          subject.run
        end
      end

      context "when ssl_verify: false is passed as an option" do
        subject { Uploader.new(berksfile, ssl_verify: false) }

        it "uses the passed option" do
          expect(Ridley).to receive(:open).with(
            server_url:  chef_config.chef_server_url,
            client_name: chef_config.node_name,
            client_key:  chef_config.client_key,
            ssl: {
              verify: false,
              cert_store: cert_store,
            }
          )
          subject.run
        end
      end

      context "when a Chef Server url is passed as an option" do
        subject { Uploader.new(berksfile, server_url: "http://custom") }

        it "uses the passed in :server_url" do
          expect(Ridley).to receive(:open)
            .with(include(server_url: "http://custom"))
          subject.run
        end
      end

      context "when a client name is passed as an option" do
        subject { Uploader.new(berksfile, client_name: "custom") }

        it "uses the passed in :client_name" do
          expect(Ridley).to receive(:open)
            .with(include(client_name: "custom"))
          subject.run
        end
      end

      context "when a client key is passed as an option" do
        subject { Uploader.new(berksfile, client_key: "custom") }

        it "uses the passed in :client_key" do
          expect(Ridley).to receive(:open)
            .with(include(client_key: "custom"))
          subject.run
        end
      end
    end
  end
end
