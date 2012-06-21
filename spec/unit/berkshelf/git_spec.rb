require 'spec_helper'

module Berkshelf
  describe Git do
    describe "ClassMethods" do
      subject { Git }

      describe "#find_git" do
        it "should find git" do
          subject.find_git.should_not be_nil
        end

        it "should raise if it can't find git" do
          begin
            path = ENV["PATH"]
            ENV["PATH"] = ""

            lambda { subject.find_git }.should raise_error
          ensure
            ENV["PATH"] = path
          end
        end
      end

      describe "#clone" do
        let(:target) { tmp_path.join("nginx") }

        it "clones the repository to the target path" do
          subject.clone("git://github.com/opscode-cookbooks/nginx.git", target)

          target.should exist
          target.should be_directory
        end
      end

      describe "#checkout" do
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

      describe "#rev_parse" do
        let(:repo_path) { tmp_path.join("nginx") }
        before(:each) do
          subject.clone("git://github.com/opscode-cookbooks/nginx.git", repo_path)
          subject.checkout(repo_path, "0e4887d9eef8cb83972f974a85890983c8204c3b")
        end

        it "returns the ref for HEAD" do
          subject.rev_parse(repo_path).should eql("0e4887d9eef8cb83972f974a85890983c8204c3b")
        end
      end
    end
  end
end
