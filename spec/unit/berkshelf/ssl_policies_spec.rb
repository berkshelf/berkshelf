require "spec_helper"

describe Berkshelf::SSLPolicy do
  let(:self_signed_crt_path) { File.join(BERKS_SPEC_DATA, "trusted_certs") }
  let(:self_signed_crt_path_windows_backslashes) { "C:/users/vagrant\\.chef\\trusted_certs" }
  let(:self_signed_crt_path_windows_forwardslashes) { "C:/users/vagrant/.chef/trusted_certs" }

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
    double(Berkshelf::Config,
      ssl:  double(verify: true),
      chef: chef_config
    )
  end

  subject do
    Berkshelf::SSLPolicy.new()
  end

  before do
    allow(Berkshelf).to receive(:config).and_return(berkshelf_config)
  end

  describe "#initialize" do
    it "sets up the store" do
      expect(subject.store.class).to be(OpenSSL::X509::Store)
    end

    it "sets up custom certificates for chef" do
    end
  end

  describe "#trusted_certs_dir" do
    it "uses the trusted_certs_dir from Berkshelf config" do
      expect(subject.trusted_certs_dir).to eq(self_signed_crt_path)
    end

    context "trusted_certs_dir in Berkshelf" do

      context "config is not set" do
        before { allow(chef_config).to receive_messages(trusted_certs_dir: nil) }

        it "defaults to ~/.chef/trusted_certs" do
          expect(subject.trusted_certs_dir).to eq(
            File.join(ENV["HOME"], ".chef", "trusted_certs")
          )
        end
      end

      context "config is set but does not exist" do
        before { allow(chef_config).to receive_messages(trusted_certs_dir: "/fake") }

        it "defaults to ~/.chef/trusted_certs" do
          expect(subject.trusted_certs_dir).to eq(
            File.join(ENV["HOME"], ".chef", "trusted_certs")
          )
        end
      end

      context "config has Windows backslashes in trusted_certs_dir path" do
        before do
          allow(chef_config).to receive_messages(trusted_certs_dir: self_signed_crt_path_windows_backslashes)
          allow(File).to receive(:exist?).with(self_signed_crt_path_windows_forwardslashes).and_return(true)
          allow(Dir).to receive(:chdir).with(self_signed_crt_path_windows_forwardslashes)
        end

        it "replaces the backslashes in trusted_certs_dir from Berkshelf config with forwardslashes" do
          expect(subject.trusted_certs_dir).to eq(
            self_signed_crt_path_windows_forwardslashes
          )
        end
      end
    end
  end
end
