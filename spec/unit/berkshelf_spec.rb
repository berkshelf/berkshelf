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
          include Berkshelf::Formatters::AbstractFormatter
          register_formatter :custom
        end

        before do
          Berkshelf.set_format :custom
        end

        it "should be the custom class" do
          Berkshelf.formatter.should be_an_instance_of(CustomFormatter)
        end
      end
    end
  end
end
