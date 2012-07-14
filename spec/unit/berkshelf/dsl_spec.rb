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
      it "calls add source to the instance of the implementing class with a CookbookSource" do
        subject.should_receive(:add_source).with(kind_of(CookbookSource))
        
        subject.cookbook "ntp"
      end
    end

    describe '#group' do
      it "calls add source to the instance of the implementing class with a CookbookSource" do
        subject.should_receive(:add_source).with(kind_of(CookbookSource))
        
        subject.group "awesome" do
          subject.cookbook "ntp"
        end
      end
    end

    describe "#metadata" do
      before(:each) do
        Dir.chdir fixtures_path.join('cookbooks/example_cookbook')
      end

      it "calls add source to the instance of the implementing class with a CookbookSource" do
        subject.should_receive(:add_source).with(kind_of(CookbookSource))
        
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
