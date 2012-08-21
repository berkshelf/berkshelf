require 'spec_helper'

describe Berkshelf do
  context "ClassMethods" do
    subject { Berkshelf }

    describe "::find_metadata" do
      let(:metadata_path) { fixtures_path.join("cookbooks", "example_cookbook", "metadata.rb") }

      context "given a path containing a metadata.rb file" do
        it "returns the path to the metadata.rb file" do
          subject.find_metadata(fixtures_path.join("cookbooks", "example_cookbook")).should eql(metadata_path)
        end
      end

      context "given a path where a parent path contains a metadata.rb file" do
        it "returns the path to the metadata.rb file" do
          subject.find_metadata(fixtures_path.join("cookbooks", "example_cookbook", "recipes")).should eql(metadata_path)
        end
      end

      context "given a path that does not contain a metadata.rb file or a parent path that does" do
        it "returns nil" do
          subject.find_metadata(tmp_path).should be_nil
        end
      end
    end

    describe "::config_path" do
      it "returns a default value if nothing is specified" do
        subject.config_path.should eql(Berkshelf::DEFAULT_CONFIG)
      end

      it "returns the value assigned if specified" do
        subject.config_path = value = "/Users/reset/.chef/knife.rb"

        subject.config_path.should eql(value)
      end
    end

    describe "::load_config" do
      it "loads the path specified by config_path if no parameter given" do
        Chef::Config.should_receive(:from_file).with(Berkshelf.config_path)

        subject.load_config
      end
    end

    describe "::formatter" do
      context "with default formatter" do
        it "should be human readable" do
          Berkshelf.formatter.should be_an_instance_of(Berkshelf::Formatters::HumanReadable)
        end
      end

      context "with a custom formatter" do
        before(:all) do
          Berkshelf.instance_eval { @formatter = nil }
        end

        class CustomFormatter
          include Berkshelf::Formatters::Formatter
          Berkshelf.formatters["custom"] = self
        end

        before do
          Berkshelf.set_format "custom"
        end

        it "should be the custom class" do
          Berkshelf.formatter.should be_an_instance_of(CustomFormatter)
        end
      end
    end
  end
end
