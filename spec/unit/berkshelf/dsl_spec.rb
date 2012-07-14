require 'spec_helper'
require 'berkshelf/dsl'

module Berkshelf
  describe DSL do
    subject do
      Class.new do
        include Berkshelf::DSL
      end.new
    end

    describe "#cookbook" do
      let(:name) { "artifact" }
      let(:constraint) { double('constraint') }
      let(:default_options) { { group: [] } }

      it "sends the add_source message with the name, constraint, and options to the instance of the includer" do
        subject.should_receive(:add_source).with(name, constraint, default_options)

        subject.cookbook name, constraint, default_options
      end

      it "merges the default options into specified options" do
        subject.should_receive(:add_source).with(name, constraint, path: "/Users/reset", group: [])

        subject.cookbook name, constraint, path: "/Users/reset"
      end

      it "converts a single specified group option into an array of groups" do
        subject.should_receive(:add_source).with(name, constraint, group: [:production])

        subject.cookbook name, constraint, group: :production
      end

      context "when no constraint specified" do
        it "sends the add_source message with a nil value for constraint" do
          subject.should_receive(:add_source).with(name, nil, default_options)

          subject.cookbook name, default_options
        end
      end

      context "when no options specified" do
        it "sends the add_source message with an empty Hash for the value of options" do
          subject.should_receive(:add_source).with(name, constraint, default_options)

          subject.cookbook name, constraint
        end
      end
    end

    describe '#group' do
      let(:name) { "artifact" }
      let(:group) { "production" }

      it "sends the add_source message with an array of groups determined by the parameter passed to the group block" do
        subject.should_receive(:add_source).with(name, nil, group: [group])
        
        subject.group group do
          subject.cookbook name
        end
      end
    end

    describe "#metadata" do
      let(:cb_path) { fixtures_path.join('cookbooks/example_cookbook').to_s }

      before(:each) { Dir.chdir(cb_path) }

      it "sends the add_source message with an explicit version constraint and the path to the cookbook" do
        subject.should_receive(:add_source).with("example_cookbook", "= 0.5.0", path: cb_path)
        
        subject.metadata
      end
    end

    describe "#site" do
      let(:uri) { "http://opscode/v1" }

      it "sends the add_location to the instance of the implementing class with a SiteLocation" do
        subject.should_receive(:add_location).with(:site, uri)

        subject.site(uri)
      end

      context "given the symbol :opscode" do
        it "sends an add_location message with the default Opscode Community API as the first parameter" do
          subject.should_receive(:add_location).with(:site, :opscode)

          subject.site(:opscode)
        end
      end
    end

    describe "#chef_api" do
      let(:uri) { "http://chef:8080/" }

      it "sends and add_location message with the type :chef_api and the given URI" do
        subject.should_receive(:add_location).with(:chef_api, uri, {})

        subject.chef_api(uri)
      end

      it "also sends any options passed" do
        options = { node_name: "reset", client_key: "/Users/reset/.chef/reset.pem" }
        subject.should_receive(:add_location).with(:chef_api, uri, options)

        subject.chef_api(uri, options)
      end

      context "given the symbol :knife" do
        it "sends an add_location message with the the type :chef_api and the URI :knife" do
          subject.should_receive(:add_location).with(:chef_api, :knife, {})

          subject.chef_api(:knife)
        end
      end
    end
  end
end
