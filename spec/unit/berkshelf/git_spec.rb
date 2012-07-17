require 'spec_helper'

module Berkshelf
  describe Git do
    describe "ClassMethods" do
      subject { Git }

      describe "::find_git" do
        it "should find git" do
          subject.find_git.should_not be_nil
        end

        it "should raise if it can't find git" do
          ENV.should_receive(:[]).with("PATH").and_return(String.new)
          
          lambda {
            subject.find_git
          }.should raise_error(GitNotFound)
        end
      end

      describe "::clone" do
        let(:target) { tmp_path.join("nginx") }

        it "clones the repository to the target path" do
          subject.clone("git://github.com/opscode-cookbooks/nginx.git", target)

          target.should exist
          target.should be_directory
        end
      end

      describe "::checkout" do
        let(:repo_path) { tmp_path.join("nginx") }
        let(:repo) { subject.clone("git://github.com/opscode-cookbooks/nginx.git", repo_path) }
        let(:tag) { "0.101.2" }

        it "checks out the specified path of the given repository" do
          subject.checkout(repo, tag)

          Dir.chdir repo_path do
            %x[git rev-parse #{tag}].should == %x[git rev-parse HEAD]
          end
        end
      end

      describe "::rev_parse" do
        let(:repo_path) { tmp_path.join("nginx") }
        before(:each) do
          subject.clone("git://github.com/opscode-cookbooks/nginx.git", repo_path)
          subject.checkout(repo_path, "0e4887d9eef8cb83972f974a85890983c8204c3b")
        end

        it "returns the ref for HEAD" do
          subject.rev_parse(repo_path).should eql("0e4887d9eef8cb83972f974a85890983c8204c3b")
        end
      end

      let(:readonly_uri) { "git://github.com/reset/thor-foodcritic.git" }
      let(:https_uri) { "https://github.com/reset/solve.git" }
      let(:ssh_uri) { "git@github.com:reset/solve.git" }
      let(:http_uri) { "http://github.com/reset/solve.git" }
      let(:invalid_uri) { "/something/on/disk" }

      describe "::validate_uri" do
        context "given a valid Git read-only URI" do
          it "returns true" do
            subject.validate_uri(readonly_uri).should be_true
          end
        end

        context "given a valid Git HTTPS URI" do
          it "returns true" do
            subject.validate_uri(https_uri).should be_true
          end
        end

        context "given a valid Git SSH URI" do
          it "returns true" do
            subject.validate_uri(ssh_uri).should be_true
          end
        end

        context "given an invalid URI" do
          it "returns false" do
            subject.validate_uri(invalid_uri).should be_false
          end
        end

        context "given a HTTP URI" do
          it "returns false" do
            subject.validate_uri(http_uri).should be_false
          end
        end

        context "given an integer" do
          it "returns false" do
            subject.validate_uri(123).should be_false
          end
        end
      end

      describe "::validate_uri!" do
        context "given a valid Git read-only URI" do
          it "returns true" do
            subject.validate_uri!(readonly_uri).should be_true
          end
        end

        context "given a valid Git HTTPS URI" do
          it "returns true" do
            subject.validate_uri!(https_uri).should be_true
          end
        end

        context "given a valid Git SSH URI" do
          it "returns true" do
            subject.validate_uri!(ssh_uri).should be_true
          end
        end

        context "given an invalid URI" do
          it "raises InvalidGitURI" do
            lambda {
              subject.validate_uri!(invalid_uri)
            }.should raise_error(InvalidGitURI)
          end
        end

        context "given a HTTP URI" do
          it "raises InvalidGitURI" do
            lambda {
              subject.validate_uri!(http_uri)
            }.should raise_error(InvalidGitURI)
          end
        end

        context "given an integer" do
          it "raises InvalidGitURI" do
            lambda {
              subject.validate_uri!(123)
            }.should raise_error(InvalidGitURI)
          end
        end
      end
    end
  end
end
