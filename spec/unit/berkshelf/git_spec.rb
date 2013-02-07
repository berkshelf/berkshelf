require 'spec_helper'

describe Berkshelf::Git do
  describe "ClassMethods" do
    subject { Berkshelf::Git }

    describe "::find_git" do
      it "should find git" do
        expect(subject.find_git).not_to be_nil
      end

      it "should raise if it can't find git" do
        ENV.should_receive(:[]).with("PATH").and_return(String.new)

        expect {
          subject.find_git
        }.to raise_error(Berkshelf::GitNotFound)
      end
    end

    describe "::clone" do
      let(:target) { clone_target_for('nginx') }

      it "clones the repository to the target path" do
        origin_uri = generate_git_origin_for("nginx")
        subject.clone(origin_uri, target)
        expect(target).to exist
        expect(target).to be_directory
      end
    end

    describe "::checkout" do
      let(:repo_path) { clone_target_for('nginx') }
      let(:repo) { 
        origin_uri = generate_git_origin_for('nginx', tags: ['1.0.1'])
        subject.clone(origin_uri, repo_path)
      }
      let(:tag) { "1.0.1" }

      it "checks out the specified path of the given repository" do
        subject.checkout(repo, tag)

        Dir.chdir repo_path do
          expect(%x[git rev-parse #{tag}]).to eq(%x[git rev-parse HEAD])
        end
      end
    end

    describe "::rev_parse" do
      let(:repo_path) { clone_target_for('nginx') }
      before(:each) do |example|
        origin_uri = generate_git_origin_for('nginx', tags: ['1.1.1'])
        subject.clone(origin_uri, repo_path)
        subject.checkout(repo_path, git_sha_for_tag('nginx', '1.1.1'))
      end

      it "returns the ref for HEAD" do
        expect(subject.rev_parse(repo_path)).to eql(git_sha_for_tag('nginx', '1.1.1'))
      end
    end

    let(:readonly_uri) { "git://github.com/reset/thor-foodcritic.git" }
    let(:https_uri) { "https://github.com/reset/solve.git" }
    let(:http_uri) { "http://github.com/reset/solve.git" }
    let(:invalid_uri) { "/something/on/disk" }

    describe "::validate_uri" do
      context "given a valid Git read-only URI" do
        it "returns true" do
          expect(subject.validate_uri(readonly_uri)).to be_true
        end
      end

      context "given a valid Git HTTPS URI" do
        it "returns true" do
          expect(subject.validate_uri(https_uri)).to be_true
        end
      end

      context "given a valid Github SSH URI" do
        it "returns true" do
          expect(subject.validate_uri("git@github.com:reset/solve.git")).to be_true
        end
      end

      context "given a valid SSH URI without an 'organization'" do
        it "returns true" do
          expect(subject.validate_uri("gituser@githost:solve.git")).to be_true
        end
      end

      context "given a valid git+ssh URI without an username" do
        it "returns true" do
          expect(subject.validate_uri("git+ssh://host.com/repo")).to be_true
        end
      end

      context "given a valid git+ssh URI with an username" do
        it "returns true" do
          expect(subject.validate_uri("git+ssh://user@host.com/repo")).to be_true
        end
      end

      context "given a valid URI with a dash in the hostname" do
        it "returns true" do
          expect(subject.validate_uri("git://user@git-host.com/repo")).to be_true
        end
      end

      context "given a valid URI with host being a subdomain" do
        it "returns true" do
          expect(subject.validate_uri("git://user@git.host.com/repo")).to be_true
        end
      end

      context "given a valid git+ssh URI with home directory expansion" do
        it "returns true" do
          expect(subject.validate_uri("git+ssh://user@host.com/~repo")).to be_true
        end
      end

      context "given an invalid URI" do
        it "returns false" do
          expect(subject.validate_uri(invalid_uri)).to be_false
        end
      end

      context "given a HTTP URI" do
        it "returns true" do
          expect(subject.validate_uri(http_uri)).to be_true
        end
      end

      context "given an integer" do
        it "returns false" do
          expect(subject.validate_uri(123)).to be_false
        end
      end
    end

    describe "::validate_uri!" do
      context "given a valid Git read-only URI" do
        it "returns true" do
          expect(subject.validate_uri!(readonly_uri)).to be_true
        end
      end

      context "given a valid Git HTTPS URI" do
        it "returns true" do
          expect(subject.validate_uri!(https_uri)).to be_true
        end
      end

      context "given a valid Git SSH URI" do
        it "returns true" do
          expect(subject.validate_uri!("git@github.com:reset/solve.git")).to be_true
        end
      end

      context "given a valid SSH URI without an 'organization'" do
        it "returns true" do
          expect(subject.validate_uri("gituser@githost:solve.git")).to be_true
        end
      end

      context "given an invalid URI" do
        it "raises InvalidGitURI" do
          expect {
            subject.validate_uri!(invalid_uri)
          }.to raise_error(Berkshelf::InvalidGitURI)
        end
      end

      context "given a HTTP URI" do
        it "raises InvalidGitURI" do
          expect(subject.validate_uri!(http_uri)).to be_true
        end
      end

      context "given an integer" do
        it "raises InvalidGitURI" do
          expect {
            subject.validate_uri!(123)
          }.to raise_error(Berkshelf::InvalidGitURI)
        end
      end
    end
  end
end
