require "spec_helper"

module Berkshelf
  describe Uploader do
    let(:berksfile) do
      double(Berksfile,
        lockfile: lockfile,
        dependencies: [])
    end

    let(:lockfile) do
      double(Lockfile,
        graph: graph)
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
      let(:options) { {} }

      let(:chef_config) do
        double(Berkshelf::ChefConfigCompat,
          node_name: "fake-client",
          client_key: "client-key",
          chef_server_url: "http://configured-chef-server/",
          validation_client_name: "validator",
          validation_key: "validator.pem",
          artifactory_api_key: "secret",
          cookbook_copyright: "user",
          cookbook_email: "user@example.com",
          cookbook_license: "apachev2",
          trusted_certs_dir: self_signed_crt_path)
      end

      let(:berkshelf_config) do
        double(Config,
          ssl:  double(verify: true),
          chef: chef_config)
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
          expect(Berkshelf::RidleyCompat).to receive(:new_client).with(
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
          expect(Berkshelf::RidleyCompat).to receive(:new_client).with(
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
          expect(Berkshelf::RidleyCompat).to receive(:new_client)
            .with(include(server_url: "http://custom"))
          subject.run
        end
      end

      context "when a client name is passed as an option" do
        subject { Uploader.new(berksfile, client_name: "custom") }

        it "uses the passed in :client_name" do
          expect(Berkshelf::RidleyCompat).to receive(:new_client)
            .with(include(client_name: "custom"))
          subject.run
        end
      end

      context "when a client key is passed as an option" do
        subject { Uploader.new(berksfile, client_key: "custom") }

        it "uses the passed in :client_key" do
          expect(Berkshelf::RidleyCompat).to receive(:new_client)
            .with(include(client_key: "custom"))
          subject.run
        end
      end
    end

    describe "#lookup_dependencies" do
      before do
        allow_any_instance_of(Berkshelf::Berksfile).to receive(:lockfile).and_return(lockfile)
      end

      let(:berksfile) { Berkshelf::Berksfile.from_file(fixtures_path.join("berksfiles/default")) }
      let(:lockfile) { Berkshelf::Lockfile.from_file(fixtures_path.join("lockfiles/default.lock")) }

      context "when given a cookbook that has no dependencies" do
        subject { described_class.new(berksfile).send(:lookup_dependencies, "yum") }

        it "returns empty array" do
          expect(subject).to eq []
        end
      end

      context "when given a cookbook that has dependencies" do
        subject { described_class.new(berksfile).send(:lookup_dependencies, "yum-epel") }

        it "returns array of cookbook's dependencies" do
          expect(subject).to eq ["yum"]
        end
      end

      context "when given a cookbook that has dependencies which have dependencies" do
        subject { described_class.new(berksfile).send(:lookup_dependencies, "runit") }

        it "returns array of cookbook's dependencies and their dependencies" do
          expect(subject).to eq %w{build-essential yum yum-epel}
        end
      end
    end

    describe "#filtered_cookbooks" do
      context "when iterating over a list of of cookbooks that have dependencies" do
        before do
          allow_any_instance_of(Berkshelf::Dependency).to receive(:berksfile).and_return(berksfile)
          allow_any_instance_of(Berkshelf::Berksfile).to receive(:lockfile).and_return(lockfile)
          allow(Berkshelf::CookbookStore).to receive(:instance).and_return(cookbook_store)
        end

        let(:berksfile) { Berkshelf::Berksfile.from_file(fixtures_path.join("berksfiles/default")) }
        let(:lockfile) { Berkshelf::Lockfile.from_file(fixtures_path.join("lockfiles/default.lock")) }
        let(:cookbook_store) { Berkshelf::CookbookStore.new(fixtures_path.join("cookbook-path-uploader")) }

        subject { described_class.new(berksfile).send(:filtered_cookbooks) }

        it "returns filtered list in correct order" do
          upload_order = subject.map(&:name)
          # assert that dependent cookbooks are uploaded before the cookbooks that depend on them
          expect(upload_order.index("apt")).to be < upload_order.index("jenkins")
          expect(upload_order.index("runit")).to be < upload_order.index("jenkins")
          expect(upload_order.index("yum")).to be < upload_order.index("jenkins")
          expect(upload_order.index("jenkins")).to be < upload_order.index("jenkins-config")
          expect(upload_order.index("yum")).to be < upload_order.index("jenkins-config")
          expect(upload_order.index("build-essential")).to be < upload_order.index("runit")
          expect(upload_order.index("yum")).to be < upload_order.index("runit")
          expect(upload_order.index("yum-epel")).to be < upload_order.index("runit")
          expect(upload_order.index("yum")).to be < upload_order.index("yum-epel")
          expect(upload_order.uniq.length).to eql(upload_order.length)
        end
      end
    end
  end
end
