require 'spec_helper'

module Remy
  describe Git do

    it "should find git" do
      Git.find_git.should_not be_nil
    end

    it "should raise if it can't find git" do
      begin
        path = ENV["PATH"]
        ENV["PATH"] = ""

        lambda { Git.find_git }.should raise_error
      ensure
        ENV["PATH"] = path
      end
    end
    
    describe "instances" do
      subject { Git.new("https://github.com/erikh/chef-ssh_known_hosts2.git") }

      after do
        subject.clean
      end

      it "should be set the repository accessor" do
        subject.repository.should == "https://github.com/erikh/chef-ssh_known_hosts2.git"
      end

      it "should be able to clone this repository" do
        subject.clone

        File.exist?(subject.directory).should be_true
        File.directory?(subject.directory).should be_true
      end

      it "should clone, then pull if the directory is the same" do
        subject.clone
        dir = subject.directory
        subject.clone
        dir2 = subject.directory

        dir.should == dir2
      end
    end
  end
end
