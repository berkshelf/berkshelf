require 'spec_helper'

describe Berkshelf::Config do
  let(:klass) { described_class }

  describe "ClassMethods" do
    subject { klass }

    describe "::file" do
      subject { klass.file }

      context "when the file does not exist" do
        before :each do
          File.stub exists?: false
        end

        it { should be_nil }
      end
    end

    describe "::instance" do
      subject { klass.instance }

      it { should be_a klass }
    end

    describe "::path" do
      subject { klass.path }

      it { should be_a String }

      it "points to a location within ENV['BERKSHELF_PATH']" do
        ENV.stub(:[]).with('BERKSHELF_PATH').and_return('/tmp')

        subject.should eql("/tmp/config.json")
      end
    end

    describe "::chef_config" do
      it "returns the Chef::Config" do
        subject.chef_config.should eql(Chef::Config)
      end
    end

    describe "::chef_config_path" do
      subject { klass.chef_config_path }

      it { should be_a String }  
    end
  end
end
