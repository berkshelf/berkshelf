require 'spec_helper'

module KnifeCookbookDependencies
  describe CookbookSource do
    describe CookbookSource::SiteLocation do
      describe "#download" do
        subject { CookbookSource::SiteLocation.new("nginx") }

        it "downloads the cookbook to the given destination" do
          subject.download(tmp_path)

          tmp_path.should have_structure {
            directory "nginx" do
              file "metadata.rb"
            end
          }
        end

        it "returns the path to the cookbook" do
          subject.download(tmp_path).should eql(tmp_path.join('nginx').to_s)
        end

        context "given an explicit version_string" do
          subject { CookbookSource::SiteLocation.new("nginx", :version_string => "0.101.2") }
        end

        context "given an explicit :site location key" do
          subject { CookbookSource::SiteLocation.new("nginx", :site => "http://cookbooks.opscode.com/api/v1/cookbooks") }
        end

        context "given a cookbook that does not exist on the specified site" do
          subject { CookbookSource::SiteLocation.new("nowaythis_exists", :site => "http://cookbooks.opscode.com/api/v1/cookbooks") }

          it "raises a CookbookNotFound error" do
            lambda {
              subject.download(tmp_path)
              }.should raise_error(CookbookNotFound)
          end
        end
      end
    end

    describe CookbookSource::GitLocation do
      subject { CookbookSource::GitLocation.new("nginx", :git => "git://github.com/opscode-cookbooks/nginx.git") }

      describe "#download" do
        it "downloads the cookbook to the given destination" do
          subject.download(tmp_path)

          tmp_path.should have_structure {
            directory "nginx" do
              file "metadata.rb"
            end
          }
        end

        it "returns the path to the cookbook" do
          subject.download(tmp_path).should eql(tmp_path.join('nginx').to_s)
        end

        context "given a git repo that does not exist" do
          subject { CookbookSource::GitLocation.new("doesnot_exist", :git => "git://github.com/RiotGames/thisrepo_does_not_exist.git") }

          it "raises a CookbookNotFound error" do
            lambda {
              subject.download(tmp_path)
            }.should raise_error(CookbookNotFound)
          end
        end

        context "given a git repo that does not contain a cookbook" do
          subject { CookbookSource::GitLocation.new("doesnot_exist", :git => "git://github.com/RiotGames/knife_cookbook_dependencies.git") }

          it "raises a CookbookNotFound error" do
            lambda {
              subject.download(tmp_path)
            }.should raise_error(CookbookNotFound)
          end
        end
      end
    end

    describe CookbookSource::PathLocation do
      let(:path) { fixtures_path.join("cookbooks", "example_cookbook").to_s }
      subject { CookbookSource::PathLocation.new("nginx", :path => path) }

      describe "#download" do
        it "downloads the cookbook to the given destination" do
          subject.download(tmp_path)

          tmp_path.should_not have_structure {
            directory "example_cookbook" do
              file "metadata.rb"
            end
          }
        end

        it "returns the path to the cookbook" do
          subject.download(tmp_path).should eql(path)
        end

        context "given a path that does not exist" do
          subject { CookbookSource::PathLocation.new("doesnot_exist", :path => tmp_path.join("doesntexist_noway")) }

          it "raises a CookbookNotFound error" do
            lambda {
              subject.download(tmp_path)
            }.should raise_error(CookbookNotFound)
          end
        end

        context "given a path that does not contain a cookbook" do
          subject { CookbookSource::PathLocation.new("doesnot_exist", :path => fixtures_path) }

          it "raises a CookbookNotFound error" do
            lambda {
              subject.download(tmp_path)
            }.should raise_error(CookbookNotFound)
          end
        end
      end
    end

    let(:cookbook_name) { "nginx" }

    describe "#initialize" do
      subject { CookbookSource }

      context "given no location key (i.e. :git, :path, :site)" do
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

      context "given a location key :git" do
        let(:url) { "git://url_to_git" }
        let(:source) { subject.new(cookbook_name, :git => url) }

        it "initializes a GitLocation for location" do
          source.location.should be_a(subject::GitLocation)
        end

        it "points to the given Git URL" do
          source.location.uri.should eql(url)
        end
      end

      context "given a location key :path" do
        let(:path) { "/Path/To/Cookbook" }
        let(:source) { subject.new(cookbook_name, :path => path) }

        it "initializes a PathLocation for location" do
          source.location.should be_a(subject::PathLocation)
        end

        it "points to the specified path" do
          source.location.path.should eql(path)
        end
      end

      context "given a location key :site" do
        let(:url) { "http://path_to_api/v1" }
        let(:source) { subject.new(cookbook_name, :site => url) }

        it "initializes a SiteLocation for location" do
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

    describe "#download" do
      it "should mark the source as downloaded after a successful download" do
        subject.download(tmp_path)

        subject.should be_downloaded
        subject.should be_downloaded
      end

      it "should write a value to local_path after a successful download" do
        subject.download(tmp_path)

        subject.local_path.should_not be_nil
      end
    end

    describe "#metadata" do
      it "should return the metadata of a CookbookSource that has been downloaded" do
        subject.download(tmp_path)

        subject.metadata.should be_a(Chef::Cookbook::Metadata)
      end

      it "should return nil if the CookbookSource has not been downloaded" do
        subject.metadata.should be_nil
      end
    end
  end
end
