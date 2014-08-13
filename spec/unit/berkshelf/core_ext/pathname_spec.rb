require 'spec_helper'

describe Pathname do
  describe "#cookbook?" do
    let(:cookbook_path) { tmp_path }
    let(:metadata_rb) { tmp_path.join("metadata.rb") }
    let(:metadata_json) { tmp_path.join("metadata.json") }

    subject { Pathname.new(cookbook_path) }

    context "when the path contains a metadata.json file" do
      before { FileUtils.touch(metadata_json) }

      it "is a cookbook" do
        expect(subject.cookbook?).to be(true)
      end
    end

    context "when the path contains a metadata.rb file" do
      before { FileUtils.touch(metadata_rb) }

      it "is a cookbook" do
        expect(subject.cookbook?).to be(true)
      end
    end

    context "when the path does not contain a metadata.json or metadata.rb file" do
      before { FileUtils.rm_f(metadata_rb) && FileUtils.rm_f(metadata_json) }

      it "is not a cookbook" do
        expect(subject.cookbook?).to be(false)
      end
    end
  end

  describe "#cookbook_root" do
    let(:root_path) { fixtures_path.join("cookbooks", "example_cookbook") }
    let(:cookbook_path) { root_path }
    subject { Pathname.new(cookbook_path) }

    context "when in the root of a cookbook" do
      it "has the correct root" do
        expect(subject.cookbook_root).to eq(root_path)
      end
    end

    context "when in the structure of a cookbook" do
      let(:cookbook_path) { root_path.join("recipes") }

      it "has the correct root" do
        expect(subject.cookbook_root).to eq(root_path)
      end
    end

    context "when not within the structure of a cookbook" do
      let(:cookbook_path) { "/" }

      it "has the correct root" do
        expect(subject.cookbook_root).to be(nil)
      end
    end
  end
end
