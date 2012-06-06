require 'spec_helper'

module KnifeCookbookDependencies
  describe CookbookSource do
    describe CookbookSource::SiteLocation do
      describe "ClassMethods" do
        subject { CookbookSource::SiteLocation }
        let(:constraint) { DepSelector::VersionConstraint.new("~> 0.101.2") }
        let(:versions) do
          { 
            DepSelector::Version.new("0.101.2") => "http://cookbooks.opscode.com/api/v1/cookbooks/nginx/versions/0_101_2",
            DepSelector::Version.new("0.101.0") => "http://cookbooks.opscode.com/api/v1/cookbooks/nginx/versions/0_101_0",
            DepSelector::Version.new("0.100.2") => "http://cookbooks.opscode.com/api/v1/cookbooks/nginx/versions/0_100_2",
            DepSelector::Version.new("0.100.0") => "http://cookbooks.opscode.com/api/v1/cookbooks/nginx/versions/0_100_0"
          }
        end

        describe "#solve_for_constraint" do
          it "returns an array containing a DepSelector::Version at index 0" do
            result = subject.solve_for_constraint(constraint, versions)

            result[0].should be_a(DepSelector::Version)
          end

          it "returns an array containing a URI at index 0" do
            result = subject.solve_for_constraint(constraint, versions)

            result[1].should match(URI.regexp)
          end

          it "should return the best match for the constraint and versions given" do
            subject.solve_for_constraint(constraint, versions)[0].to_s.should eql("0.101.2")
          end
        end
      end

      subject { CookbookSource::SiteLocation.new("nginx") }

      describe "#download" do
        it "returns the path to the cookbook" do
          result = subject.download(tmp_path)
          name = subject.name
          ver, uri = subject.latest_version

          result.should eql(tmp_path.join("#{name}-#{ver}").to_s)
        end

        context "when no version constraint is specified" do
          it "the latest version of the cookbook is downloaded to the given destination" do
            subject.download(tmp_path)
            name = subject.name
            ver, uri = subject.latest_version

            tmp_path.should have_structure {
              directory "#{name}-#{ver}" do
                file "metadata.rb"
              end
            }
          end
        end

        context "given an explicit version_constraint" do
          subject { CookbookSource::SiteLocation.new("nginx", :version_constraint => DepSelector::VersionConstraint.new("= 0.101.2")) }

          it "downloads the cookbook with the version matching the version_constraint to the given destination" do
            subject.download(tmp_path)
            name = subject.name

            tmp_path.should have_structure {
              directory "#{name}-0.101.2" do
                file "metadata.rb"
              end
            }
          end
        end

        context "given a more broad version_constraint" do
          subject { CookbookSource::SiteLocation.new("nginx", :version_constraint => DepSelector::VersionConstraint.new("~> 0.99.0")) }

          it "downloads the best matching cookbook version for the constraint to the given destination" do
            subject.download(tmp_path)
            name = subject.name

            tmp_path.should have_structure {
              directory "#{name}-0.99.2" do
                file "metadata.rb"
              end
            }
          end
        end

        context "given an explicit :site location key" do
          subject { CookbookSource::SiteLocation.new("nginx", :site => "http://cookbooks.opscode.com/api/v1/cookbooks") }

          it "downloads the cookbook to the given destination" do
            subject.download(tmp_path)
            name = subject.name
            ver, uri = subject.latest_version

            tmp_path.should have_structure {
              directory "#{name}-#{ver}" do
                file "metadata.rb"
              end
            }
          end
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

      describe "#versions" do
        it "returns a hash containing versions for keys" do
          subject.versions.each do |key, val|
            key.should be_a(DepSelector::Version)
          end
        end

        it "returns a hash containing uris for values" do
          subject.versions.each do |key, val|
            val.should match(URI.regexp)
          end
        end
      end

      describe "#version" do
        it "returns an array containing a DepSelector::Version at index 0" do
          result = subject.version("0.101.2")

          result[0].should be_a(DepSelector::Version)
        end

        it "returns an array containing a URI at index 0" do
          result = subject.version("0.101.2")

          result[1].should match(URI.regexp)
        end

        it "returns a DepSelector::Version that matches the given version" do
          result = subject.version("0.101.2")

          result[0].to_s.should eql("0.101.2")
        end
      end

      describe "#latest_version" do
        it "returns an array containing a DepSelector::Version at index 0" do
          result = subject.latest_version

          result[0].should be_a(DepSelector::Version)
        end

        it "returns an array containing a URI at index 0" do
          result = subject.latest_version

          result[1].should match(URI.regexp)
        end
      end
    end

    describe CookbookSource::GitLocation do
      subject { CookbookSource::GitLocation.new("nginx", :git => "git://github.com/opscode-cookbooks/nginx.git") }

      describe "#download" do
        it "downloads the cookbook to the given destination" do
          subject.download(tmp_path)
          # have to set outside of custom rspec matcher block
          name, branch = subject.name, subject.branch

          tmp_path.should have_structure {
            directory "#{name}-#{branch}" do
              file "metadata.rb"
            end
          }
        end

        it "returns the path to the cookbook" do
          result = subject.download(tmp_path)
          # have to set outside of custom rspec matcher block
          name, branch = subject.name, subject.branch

          result.should eql(tmp_path.join("#{name}-#{branch}").to_s)
        end

        context "given no ref/branch/tag options is given" do
          subject { CookbookSource::GitLocation.new("nginx", :git => "git://github.com/opscode-cookbooks/nginx.git") }

          it "sets the branch attribute to the HEAD revision of the cloned repo" do
            subject.download(tmp_path)

            subject.branch.should_not be_nil
          end
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
      context "when download is successful" do
        it "writes a value to local_path" do
          subject.download(tmp_path)

          subject.local_path.should_not be_nil
        end

        it "writes a value to local_version" do
          subject.download(tmp_path)

          subject.local_version.should_not be_nil
        end

        it "returns an array containing the symbol :ok and the local_path" do
          result = subject.download(tmp_path)

          result.should be_a(Array)
          result[0].should eql(:ok)
          result[1].should eql(subject.local_path)
        end
      end

      context "when the download fails" do
        let(:bad_cb_name) { "NOWAYTHISEXISTS" }
        subject { CookbookSource.new(bad_cb_name) }

        it "returns an array containing the symbol :error and the error message" do
          result = subject.download(tmp_path)

          result.should be_a(Array)
          result[0].should eql(:error)
          result[1].should eql("Cookbook '#{bad_cb_name}' not found at site: 'http://cookbooks.opscode.com/api/v1/cookbooks'")
        end
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

    describe "#downloaded?" do
      context "given a source with a PathLocation" do
        let(:path) { fixtures_path.join("cookbooks", "example_cookbook").to_s }
        subject { CookbookSource.new("example_cookbook", :path => path) }

        it "returns true if the PathLocation is downloaded" do
          subject.download(tmp_path)

          subject.downloaded?(tmp_path).should be_true
        end

        it "returns false if the PathLocation does not exist" do
          source = CookbookSource.new("doesnot_exist", :path => tmp_path.join("doesntexist_noway").to_s)

          source.downloaded?(tmp_path).should be_false
        end
      end

      context "given a source with a GitLocation" do
        subject { CookbookSource.new("nginx", :git => "git://github.com/opscode-cookbooks/nginx.git") }

        it "returns true if the GitLocation is downloaded" do
          subject.download(tmp_path)

          subject.downloaded?(tmp_path).should be_true
        end

        it "returns false if the GitLocation is not downloaded" do
          subject.downloaded?(tmp_path).should be_false
        end
      end

      context "given a source with a SiteLocation" do
        subject { CookbookSource.new("nginx", "= 0.101.2") }

        it "returns true if the SiteLocation is downloaded" do
          subject.download(tmp_path)

          subject.downloaded?(tmp_path).should be_true
        end

        it "returns false if the SiteLocation is not downloaded" do
          subject.downloaded?(tmp_path).should be_false
        end
      end
    end
  end
end
