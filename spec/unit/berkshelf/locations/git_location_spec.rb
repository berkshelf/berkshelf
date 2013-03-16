require 'spec_helper'

describe Berkshelf::GitLocation do
  let(:complacent_constraint) { double('comp-vconstraint', satisfies?: true) }

  describe "ClassMethods" do
    subject { described_class }

    describe "::initialize" do
      it "raises InvalidGitURI if given an invalid Git URI for options[:git]" do
        lambda {
          subject.new("nginx", complacent_constraint, git: "/something/on/disk")
        }.should raise_error(Berkshelf::InvalidGitURI)
      end
    end

    describe "::tmpdir" do
      it "creates a temporary directory within the Berkshelf temporary directory" do
        subject.tmpdir.should include(Berkshelf.tmp_dir)
      end
    end
  end

  subject { described_class.new("nginx", complacent_constraint, git: "git://github.com/opscode-cookbooks/nginx.git") }

  describe "#download" do
    it "returns an instance of Berkshelf::CachedCookbook" do
      subject.download(tmp_path).should be_a(Berkshelf::CachedCookbook)
    end

    it "downloads the cookbook to the given destination" do
      cached_cookbook = subject.download(tmp_path)

      tmp_path.should have_structure {
        directory "#{cached_cookbook.cookbook_name}-#{Berkshelf::Git.rev_parse(cached_cookbook.path)}" do
          file "metadata.rb"
        end
      }
    end

    it "sets the downloaded status to true" do
      subject.download(tmp_path)

      subject.should be_downloaded
    end

    context "given no ref/branch/tag options is given" do
      subject { described_class.new("nginx", complacent_constraint, git: "git://github.com/opscode-cookbooks/nginx.git") }

      it "sets the branch attribute to the HEAD revision of the cloned repo" do
        subject.download(tmp_path)

        subject.branch.should_not be_nil
      end
    end

    context "given a git repo that does not exist" do
      subject { described_class.new("doesnot_exist", complacent_constraint, git: "git://github.com/RiotGames/thisrepo_does_not_exist.git") }

      it "raises a GitError" do
        Berkshelf::Git.stub(:git).and_raise(Berkshelf::GitError.new(''))
        lambda {
          subject.download(tmp_path)
        }.should raise_error(Berkshelf::GitError)
      end
    end

    context "given a git repo that does not contain a cookbook" do
      let(:fake_remote) { local_git_origin_path_for('not_a_cookbook') }
      subject { described_class.new("doesnot_exist", complacent_constraint, git: "file://#{fake_remote}.git") }

      it "raises a CookbookNotFound error" do
        subject.stub(:clone).and_return {
          FileUtils.mkdir_p(fake_remote)
          Dir.chdir(fake_remote) { |dir| `git init; echo hi > README; git add README; git commit README -m "README"`; dir }
        }

        lambda {
          subject.download(tmp_path)
        }.should raise_error(Berkshelf::CookbookNotFound)
      end
    end

    context "given the content at the Git repo does not satisfy the version constraint" do
      subject do
        described_class.new("nginx",
          double('constraint', satisfies?: false),
          git: "git://github.com/opscode-cookbooks/nginx.git"
        )
      end

      it "raises a CookbookValidationFailure error" do
        lambda {
          subject.download(tmp_path)
        }.should raise_error(Berkshelf::CookbookValidationFailure)
      end
    end

    context "given a value for ref that is a tag or branch and not a commit hash" do
      let(:ref) { "0.9.8" }

      subject do
        described_class.new("nginx",
          complacent_constraint,
          git: "git://github.com/opscode-cookbooks/nginx.git",
          ref: ref
        )
      end
      let(:cached_cookbook) { subject.download(tmp_path) }
      let(:commit_hash) { "d7be334b094f497f5cce4169a8b3012bf7b27bc3" }
      let(:expected_path) { tmp_path.join("#{cached_cookbook.cookbook_name}-#{commit_hash}") }

      before(:each) { Berkshelf::Git.should_receive(:rev_parse).and_return(commit_hash) }

      it "returns a cached cookbook with a path that contains the commit hash it is pointing to" do
        cached_cookbook.path.should eql(expected_path)
      end
    end
  end
end
