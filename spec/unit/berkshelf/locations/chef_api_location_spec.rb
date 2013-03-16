require 'spec_helper'

describe Berkshelf::ChefAPILocation, :chef_server do
  let(:test_chef_api) { "https://chefserver:8081" }

  describe "ClassMethods" do
    subject { described_class }

    let(:valid_uri) { test_chef_api }
    let(:invalid_uri) { "notauri" }
    let(:constraint) { double('constraint') }

    describe "::initialize" do
      let(:node_name) { "reset" }
      let(:client_key) { fixtures_path.join("reset.pem").to_s }

      before(:each) do
        @location = subject.new("nginx",
          constraint,
          chef_api: test_chef_api,
          node_name: node_name,
          client_key: client_key
        )
      end

      it "sets the uri attribute to the value of the chef_api option" do
        @location.uri.should eql(test_chef_api)
      end

      it "sets the node_name attribute to the value of the node_name option" do
        @location.node_name.should eql(node_name)
      end

      it "sets the client_key attribute to the value of the client_key option" do
        @location.client_key.should eql(client_key)
      end

      it "sets the downloaded status to false" do
        @location.should_not be_downloaded
      end

      context "when an invalid Chef API URI is given" do
        it "raises Berkshelf::InvalidChefAPILocation" do
          lambda {
            subject.new("nginx", constraint, chef_api: invalid_uri, node_name: node_name, client_key: client_key)
          }.should raise_error(Berkshelf::InvalidChefAPILocation, "'notauri' is not a valid Chef API URI.")
        end
      end

      context "when no option for node_name is supplied" do
        it "raises Berkshelf::InvalidChefAPILocation" do
          lambda {
            subject.new("nginx", constraint, chef_api: invalid_uri, client_key: client_key)
          }.should raise_error(Berkshelf::InvalidChefAPILocation)
        end
      end

      context "when no option for client_key is supplied" do
        it "raises Berkshelf::InvalidChefAPILocation" do
          lambda {
            subject.new("nginx", constraint, chef_api: invalid_uri, node_name: node_name)
          }.should raise_error(Berkshelf::InvalidChefAPILocation)
        end
      end

      context "given the symbol :config for the value of chef_api:" do
        before(:each) { @loc = subject.new("nginx", constraint, chef_api: :config) }

        it "uses the value of Berkshelf::Chef.instance.chef.chef_server_url for the uri attribute" do
          @loc.uri.should eql(Berkshelf::Config.instance.chef.chef_server_url)
        end

        it "uses the value of Berkshelf::Chef.instance.chef.node_name for the node_name attribute" do
          @loc.node_name.should eql(Berkshelf::Config.instance.chef.node_name)
        end

        it "uses the value of Berkshelf::Chef.instance.chef.client_key for the client_key attribute" do
          @loc.client_key.should eql(Berkshelf::Config.instance.chef.client_key)
        end
      end
    end

    describe "::validate_uri" do
      it "returns false if the given URI is invalid" do
        subject.validate_uri(invalid_uri).should be_false
      end

      it "returns true if the given URI is valid" do
        subject.validate_uri(valid_uri).should be_true
      end
    end

    describe "::validate_uri!" do
      it "raises Berkshelf::InvalidChefAPILocation if the given URI is invalid" do
        lambda {
          subject.validate_uri!(invalid_uri)
        }.should raise_error(Berkshelf::InvalidChefAPILocation, "'notauri' is not a valid Chef API URI.")
      end

      it "returns true if the given URI is valid" do
        subject.validate_uri!(valid_uri).should be_true
      end
    end
  end

  subject do
    described_class.new('nginx', nil, chef_api: :config)
  end

  describe "#target_cookbook" do
    let(:cookbook_version) { double('cookbook_version') }

    context "when a version constraint is present" do
      let(:constraint) { double('constraint') }

      it "returns the best solution for the constraint" do
        subject.stub(:version_constraint).and_return(constraint)
        subject.stub_chain(:conn, :cookbook, :satisfy).with(subject.name, constraint).and_return(cookbook_version)
        
        subject.target_cookbook.should eql(cookbook_version)
      end
    end

    context "when a version constraint is not present" do
      it "returns the latest version of the cookbook" do
        subject.stub(:version_constraint).and_return(nil)
        subject.stub_chain(:conn, :cookbook, :latest_version).with(subject.name).and_return(cookbook_version)

        subject.target_cookbook.should eql(cookbook_version)
      end
    end
  end

  describe "#to_s" do
    it "returns a string containing the location key and the Chef API URI" do
      subject.to_s.should eql("chef_api: '#{Berkshelf::Config.instance.chef.chef_server_url}'")
    end
  end
end
