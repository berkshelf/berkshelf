require 'spec_helper'

module Berkshelf
  describe CookbookSource::SiteLocation do
    describe "ClassMethods" do
      subject { CookbookSource::SiteLocation }

      describe "::initialize" do
        context "given the symbol :opscode for the value of URI" do
          it "creates a SiteLocation with a URI equal to the default Opscode Community Site API" do
            result = subject.new("nginx", double('constraint'), site: :opscode)

            result.api_uri.should eql(CookbookSource::Location::OPSCODE_COMMUNITY_API)
          end
        end
      end
    end

    let(:complacent_constraint) { double('comp-vconstraint', satisfies?: true) }
    subject { CookbookSource::SiteLocation.new("nginx", complacent_constraint) }

    describe "#download" do
      before(:each) do
        subject.stub(:target_version).and_return(["0.101.2", "http://cookbooks.opscode.com/api/v1/cookbooks/nginx/versions/0_101_2"])
      end

      it "returns a CachedCookbook" do
        result = subject.download(tmp_path)
        name = subject.name
        ver, uri = subject.latest_version

        result.should be_a(CachedCookbook)
      end

      it "sets the downloaded status to true" do
        subject.download(tmp_path)

        subject.should be_downloaded
      end

      context "given a wildcard '>= 0.0.0' version constraint is specified" do
        before(:each) do
          subject.stub(:latest_version).and_return(["0.101.2", "http://cookbooks.opscode.com/api/v1/cookbooks/nginx/versions/0_101_2"])
        end

        it "downloads the latest version of the cookbook to the given destination" do
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

      context "given an explicit :site location key" do
        subject do
          CookbookSource::SiteLocation.new("nginx",
            complacent_constraint,
            site: "http://cookbooks.opscode.com/api/v1/cookbooks"
          )
        end

        before(:each) do
          subject.stub(:latest_version).and_return(["0.101.2", "http://cookbooks.opscode.com/api/v1/cookbooks/nginx/versions/0_101_2"])
        end

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
        before(:each) do
          subject.stub(:versions).and_raise(CookbookNotFound)
          subject.stub(:target_version).and_raise(CookbookNotFound)
        end

        it "raises a CookbookNotFound error" do
          lambda {
            subject.download(tmp_path)
          }.should raise_error(CookbookNotFound)
        end
      end
    end

    describe "#versions" do
      it "returns a hash containing a string containing the version number of each cookbook version as the keys" do
        subject.versions.should have_key("0.101.2")
      end

      it "returns a hash containing a string containing the download URL for each cookbook version as the values" do
        subject.versions["0.101.2"].should eql("http://cookbooks.opscode.com/api/v1/cookbooks/nginx/versions/0_101_2")
      end
    end

    describe "#latest_version" do
      it "returns an array containing a version string at index 0" do
        result = subject.latest_version

        result[0].should match(/^(.+)\.(.+)\.(.+)$/)
      end

      it "returns an array containing a URI at index 1" do
        result = subject.latest_version

        result[1].should match(URI.regexp)
      end
    end
  end
end
