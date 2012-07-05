require 'spec_helper'

module Berkshelf
  describe CookbookSource::GitLocation do
    let(:complacent_constraint) { double('comp-vconstraint', include?: true) }
    
    describe "ClassMethods" do
      subject { CookbookSource::GitLocation }

      describe "::initialize" do
        it "raises InvalidGitURI if given an invalid Git URI for options[:git]" do
          lambda {
            subject.new("nginx", complacent_constraint, git: "/something/on/disk")
          }.should raise_error(InvalidGitURI)
        end
      end
    end

    subject { CookbookSource::GitLocation.new("artifact", complacent_constraint, git: "git://github.com/RiotGames/artifact-cookbook.git") }

    describe "#download" do
      it "returns an instance of Berkshelf::CachedCookbook" do
        subject.download(tmp_path).should be_a(Berkshelf::CachedCookbook)
      end

      it "downloads the cookbook to the given destination" do
        cached_cookbook = subject.download(tmp_path)

        tmp_path.should have_structure {
          directory "#{cached_cookbook.cookbook_name}-#{Git.rev_parse(cached_cookbook.path)}" do
            file "metadata.rb"
          end
        }
      end

      it "sets the downloaded status to true" do
        subject.download(tmp_path)

        subject.should be_downloaded
      end

      context "given no ref/branch/tag options is given" do
        subject { CookbookSource::GitLocation.new("nginx", complacent_constraint, git: "git://github.com/opscode-cookbooks/nginx.git") }

        it "sets the branch attribute to the HEAD revision of the cloned repo" do
          subject.download(tmp_path)

          subject.branch.should_not be_nil
        end
      end

      context "given a git repo that does not exist" do
        subject { CookbookSource::GitLocation.new("doesnot_exist", complacent_constraint, git: "git://github.com/RiotGames/thisrepo_does_not_exist.git") }

        it "raises a GitError" do
          lambda {
            subject.download(tmp_path)
          }.should raise_error(GitError)
        end
      end

      context "given a git repo that does not contain a cookbook" do
        subject { CookbookSource::GitLocation.new("doesnot_exist", complacent_constraint, git: "git://github.com/RiotGames/berkshelf.git") }

        it "raises a CookbookNotFound error" do
          lambda {
            subject.download(tmp_path)
          }.should raise_error(CookbookNotFound)
        end
      end

      context "given the content at the Git repo does not satisfy the version constraint" do
        subject do
          CookbookSource::GitLocation.new("nginx",
            double('constraint', include?: false),
            git: "git://github.com/opscode-cookbooks/nginx.git"
          )
        end

        it "raises a ConstraintNotSatisfied error" do
          lambda {
            subject.download(tmp_path)
          }.should raise_error(ConstraintNotSatisfied)
        end
      end

      context "given a value for ref that is a tag or branch and not a commit hash" do
        subject do
          CookbookSource::GitLocation.new("artifact", 
            complacent_constraint,
            git: "git://github.com/RiotGames/artifact-cookbook.git",
            ref: "0.9.8"
          )
        end

        let(:commit_hash) { "d7be334b094f497f5cce4169a8b3012bf7b27bc3" }

        before(:each) { Git.should_receive(:rev_parse).and_return(commit_hash) }

        it "returns a cached cookbook with a path that contains the commit hash it is pointing to" do
          cached_cookbook = subject.download(tmp_path)
          expected_path = tmp_path.join("#{cached_cookbook.cookbook_name}-#{commit_hash}")

          cached_cookbook.path.should eql(expected_path)
        end
      end
    end
  end
end
