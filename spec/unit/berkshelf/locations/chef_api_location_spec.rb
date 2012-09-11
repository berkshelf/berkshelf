require 'spec_helper'

module Berkshelf
  describe ChefAPILocation do
    let(:test_chef_api) { "https://chefserver:8081" }

    describe "ClassMethods" do
      subject { ChefAPILocation }
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
          it "raises InvalidChefAPILocation" do
            lambda {
              subject.new("nginx", constraint, chef_api: invalid_uri, node_name: node_name, client_key: client_key)
            }.should raise_error(InvalidChefAPILocation, "'notauri' is not a valid Chef API URI.")
          end
        end

        context "when no option for node_name is supplied" do
          it "raises InvalidChefAPILocation" do
            lambda {
              subject.new("nginx", constraint, chef_api: invalid_uri, client_key: client_key)
            }.should raise_error(InvalidChefAPILocation)
          end
        end

        context "when no option for client_key is supplied" do
          it "raises InvalidChefAPILocation" do
            lambda {
              subject.new("nginx", constraint, chef_api: invalid_uri, node_name: node_name)
            }.should raise_error(InvalidChefAPILocation)
          end
        end

        context "given the symbol :knife for the value of chef_api:" do
          before(:each) { @loc = subject.new("nginx", constraint, chef_api: :knife) }

          it "uses the value of Chef::Config[:chef_server_url] for the uri attribute" do
            @loc.uri.should eql(Chef::Config[:chef_server_url])
          end

          it "uses the value of Chef::Config[:node_name] for the node_name attribute" do
            @loc.node_name.should eql(Chef::Config[:node_name])
          end

          it "uses the value of Chef::Config[:client_key] for the client_key attribute" do
            @loc.client_key.should eql(Chef::Config[:client_key])
          end

          it "attempts to load the config file with no arguments" do
            Berkshelf.should_receive(:load_config).with(no_args)

            subject.new("nginx", constraint, chef_api: :knife)
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
        it "raises InvalidChefAPILocation if the given URI is invalid" do
          lambda {
            subject.validate_uri!(invalid_uri)
          }.should raise_error(InvalidChefAPILocation, "'notauri' is not a valid Chef API URI.")
        end

        it "returns true if the given URI is valid" do
          subject.validate_uri!(valid_uri).should be_true
        end
      end
    end

    subject do
      loc = ChefAPILocation.new("nginx",
        double('constraint', satisfies?: true),
        chef_api: :knife
      )
    end

    let(:rest) { double('rest') }

    before(:each) do
      subject.stub(:rest) { rest }
    end

    describe "#download" do
      let(:latest) { ["0.101.2", "http://chef/cookbook/nginx/0.101.2"] }
      let(:versions) do
        versions = {
          "#{subject.name}" => {
            "versions" => [
              {
                "url" => "https://api.opscode.com/organizations/vialstudios/cookbooks/#{subject.name}/0.101.2",
                "version" => "0.101.2"
              },
              {
                "url" => "https://api.opscode.com/organizations/vialstudios/cookbooks/#{subject.name}/0.99.0",
                "version" => "0.99.0"
              }
            ],
            "url" => "https://api.opscode.com/organizations/vialstudios/cookbooks/#{subject.name}"
          }
        }
      end

      before(:each) do
        subject.stub(:latest_version) { latest }
        rest.should_receive(:get_rest).with("cookbooks/#{subject.name}").and_return(versions)
      end

      context "given a constraint that matches an available cookbook" do
        before(:each) do
          cookbook_version = double('cookbook-version')
          cookbook_version.stub(:manifest).and_return({})
          subject.stub(:version_constraint) { Solve::Constraint.new("= 0.99.0") }
          rest.should_receive(:get_rest).with("https://api.opscode.com/organizations/vialstudios/cookbooks/nginx/0.99.0").and_return(cookbook_version)
          subject.should_receive(:download_files).with(cookbook_version.manifest).and_return(
            generate_cookbook(Dir.mktmpdir, subject.name, "0.99.0")
          )
        end

        it "returns an instance of Berkshelf::CachedCookbook" do
          subject.download(tmp_path).should be_a(Berkshelf::CachedCookbook)
        end

        it "sets the downloaded status to true" do
          subject.download(tmp_path)

          subject.should be_downloaded
        end
      end

      context "given a wildcard '>= 0.0.0' version constraint is specified" do
        before(:each) do
          subject.stub(:version_constraint) { Solve::Constraint.new(">= 0.0.0") }
        end

        it "downloads the manifest of the latest cookbook version of the cookbook" do
          cookbook_version = double('cookbook-version')
          cookbook_version.stub(:manifest).and_return({})
          rest.should_receive(:get_rest).with("https://api.opscode.com/organizations/vialstudios/cookbooks/nginx/0.101.2").and_return(cookbook_version)
          subject.should_receive(:download_files).with(cookbook_version.manifest).and_return(
            generate_cookbook(Dir.mktmpdir, subject.name, subject.latest_version[0])
          )

          subject.download(tmp_path)
        end
      end
    end

    describe "#versions" do
      before(:each) do
        rest = double('rest')
        subject.stub(:rest) { rest }
        response = {"nginx"=>{"versions"=>[{"url"=>"https://api.opscode.com/organizations/vialstudios/cookbooks/nginx/0.101.2", "version"=>"0.101.2"}], "url"=>"https://api.opscode.com/organizations/vialstudios/cookbooks/nginx"}}
        rest.stub(:get_rest).and_return(response)
      end

      it "returns a hash containing a string containing the version number of each cookbook version as the keys" do
        subject.versions.should have_key("0.101.2")
      end

      it "returns a hash containing a string containing the download URL for each cookbook version as the values" do
        subject.versions["0.101.2"].should eql("https://api.opscode.com/organizations/vialstudios/cookbooks/nginx/0.101.2")
      end
    end

    describe "#latest_version" do
      before(:each) do
        subject.stub(:versions).and_return(
          "0.0.1" => "https://chef/nginx/0.0.1",
          "1.0.0" => "https://chef/nginx/1.0.0",
          "0.100.0" => "https://chef/nginx/0.100.0"
        )
      end

      it "returns an array with two elements" do
        subject.latest_version.should be_a(Array)
        subject.latest_version.should have(2).items
      end

      it "returns an array containing the latest version at index 0" do
        subject.latest_version[0].should eql("1.0.0")
      end

      it "returns an array containing the URL to the latest version at index 1" do
        subject.latest_version[1].should eql("https://chef/nginx/1.0.0")
      end
    end

    describe "#to_s" do
      subject do
        ChefAPILocation.new('nginx',
          double('constraint'),
          chef_api: :knife
        )
      end

      it "returns a string containing the location key and the Chef API URI" do
        subject.to_s.should eql("chef_api: '#{Chef::Config[:chef_server_url]}'")
      end
    end
  end
end
