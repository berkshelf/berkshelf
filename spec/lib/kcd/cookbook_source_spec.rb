require 'spec_helper'

module KnifeCookbookDependencies
  describe CookbookSource do
    describe CookbookSource::SiteLocation do
      subject { CookbookSource::SiteLocation.new("sparkle_motion", "1.0.0") }

      describe "#filename" do
        it "returns a filename including the name of the cookbook and version representing an archive" do
          subject.filename.should eql("sparkle_motion-1.0.0.tar.gz")
        end

        context "given no version number specified" do
          subject { CookbookSource::SiteLocation.new("sparkle_motion") }

          it "returns a filename containing 'latest' in place of a version number" do
            subject.filename.should eql("sparkle_motion-latest.tar.gz")
          end
        end
      end
    end

    let(:cookbook_name) { "sparkle_motion" }

    describe "#initialize" do
      subject { CookbookSource }

      context "given no value for location" do
        let(:source) { subject.new(cookbook_name) }

        it "uses a default SiteLocation pointing to the opscode community api" do
          source.location.api_uri.should eql(subject::SiteLocation::OPSCODE_COMMUNITY_API)
        end
      end

      context "given no value for constraint" do
        let(:source) { subject.new(cookbook_name) }

        it "returns a wildcard match for any version" do
          source.version_constraint.to_s.should eql(">= 0.0.0")
        end
      end

      context "given a value for constraint" do
        let(:source) { subject.new(cookbook_name, "~> 1.0.84") }

        it "returns a DepSelector::VersionConstraint for the given version for version_constraint" do
          source.version_constraint.to_s.should eql("~> 1.0.84")
        end
      end

      context "given a location option :git" do
        let(:url) { "git://url_to_git" }
        let(:source) { subject.new(cookbook_name, :git => url) }

        it "returns a GitLocation for location" do
          source.location.should be_a(subject::GitLocation)
        end

        it "points to the specified URI" do
          source.location.uri.should eql(url)
        end
      end

      context "given a location option :path" do
        let(:url) { "/Path/To/Cookbook" }
        let(:source) { subject.new(cookbook_name, :path => url) }

        it "returns a PathLocation for location" do
          source.location.should be_a(subject::PathLocation)
        end

        it "points to the specified URI" do
          source.location.uri.should eql(url)
        end
      end

      context "given a location option :site" do
        let(:url) { "http://path_to_api/v1" }
        let(:source) { subject.new(cookbook_name, :site => url) }

        it "returns a SiteLocation for the location" do
          source.location.should be_a(subject::SiteLocation)
        end

        it "points to the specified URI" do
          source.location.api_uri.should eql(url)
        end
      end

      context "given multiple location options" do
        it "raises with an ArgumentError" do
          lambda {
            subject.new(cookbook_name, :site => "something", :git => "something")
          }.should raise_error(ArgumentError)
        end
      end

      context "given a group option containing a single group" do
        let(:group) { :production }
        let(:source) { subject.new(cookbook_name, :group => group) }

        it "assigns the single group to the groups attribute" do
          source.groups.should include(group)
        end
      end

      context "given a group option containing an array of groups" do
        let(:groups) { [ :development, :test ] }
        let(:source) { subject.new(cookbook_name, :group => groups) }

        it "assigns all the groups to the group attribute" do
          source.groups.should eql(groups)
        end
      end

      context "given no group option" do
        let(:source) { subject.new(cookbook_name) }

        it "should have the default group assigned" do
          source.groups.should include(:default)
        end
      end
    end

    subject { CookbookSource.new(cookbook_name) }

    describe '#add_group' do
      it "should store strings as symbols" do
        subject.add_group "foo"
        subject.groups.should == [:default, :foo]
      end

      it "should not store duplicate groups" do
        subject.add_group "bar"
        subject.add_group "bar"
        subject.add_group :bar
        subject.groups.should == [:default, :bar]
      end

      it "should add multiple groups" do
        subject.add_group "baz", "quux"
        subject.groups.should == [:default, :baz, :quux]
      end

      it "should handle multiple groups as an array" do
        subject.add_group ["baz", "quux"]
        subject.groups.should == [:default, :baz, :quux]
      end
    end
  end
end
