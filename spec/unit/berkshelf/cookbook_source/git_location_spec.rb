require 'spec_helper'

module Berkshelf
  describe CookbookSource::GitLocation do
    describe "ClassMethods" do
      subject { CookbookSource::GitLocation }

      describe "::initialize" do
        it "raises InvalidGitURI if given an invalid Git URI for options[:git]" do
          lambda {
            subject.new("nginx", git: "/something/on/disk")
          }.should raise_error(InvalidGitURI)
        end
      end
    end

    subject { CookbookSource::GitLocation.new("nginx", git: "git://github.com/opscode-cookbooks/nginx.git") }

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
        subject { CookbookSource::GitLocation.new("doesnot_exist", :git => "git://github.com/RiotGames/berkshelf.git") }

        it "raises a CookbookNotFound error" do
          lambda {
            subject.download(tmp_path)
          }.should raise_error(CookbookNotFound)
        end
      end
    end
  end
end
