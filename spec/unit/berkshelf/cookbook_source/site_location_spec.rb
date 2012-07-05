require 'spec_helper'

module Berkshelf
  describe CookbookSource::SiteLocation do
    describe "ClassMethods" do
      let(:constraint) { DepSelector::VersionConstraint.new("~> 0.101.2") }
      subject { CookbookSource::SiteLocation }
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

        context "given a solution can not be found for constraint" do
          it "returns nil" do
            subject.solve_for_constraint(DepSelector::VersionConstraint.new(">= 1.0"), versions).should be_nil
          end
        end
      end
    end

    let(:complacent_constraint) { double('comp-vconstraint', include?: true) }
    subject { CookbookSource::SiteLocation.new("nginx", complacent_constraint) }

    describe "#download" do
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
        subject { CookbookSource::SiteLocation.new("nginx", DepSelector::VersionConstraint.new(">= 0.0.0")) }

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

      context "given an exact match version constraint" do
        subject { CookbookSource::SiteLocation.new("nginx", DepSelector::VersionConstraint.new("= 0.101.2")) }

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

      context "given a more broad version constraint" do
        subject { CookbookSource::SiteLocation.new("nginx", DepSelector::VersionConstraint.new("~> 0.99.0")) }

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
        subject do
          CookbookSource::SiteLocation.new("nginx",
            complacent_constraint,
            site: "http://cookbooks.opscode.com/api/v1/cookbooks"
          )
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
        subject do
          CookbookSource::SiteLocation.new("nowaythis_exists",
            complacent_constraint,
            site: "http://cookbooks.opscode.com/api/v1/cookbooks"
          )
        end

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
end
