require 'spec_helper'

describe KnifeCookbookDependencies do
  context "ClassMethods" do
    subject { KnifeCookbookDependencies }

    describe "#find_metadata" do
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
  end
end
