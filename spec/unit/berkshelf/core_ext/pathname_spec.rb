require 'spec_helper'

describe Pathname do
  describe "#cookbook?" do
    let(:cookbook_path) { tmp_path }
    let(:metadata_rb) { tmp_path.join("metadata.rb") }
    let(:metadata_json) { tmp_path.join("metadata.json") }

    subject { Pathname.new(cookbook_path) }

    context "when the path contains a metadata.json file" do
      before { FileUtils.touch(metadata_json) }
      its(:cookbook?) { should be_true }
    end

    context "when the path contains a metadata.rb file" do
      before { FileUtils.touch(metadata_rb) }
      its(:cookbook?) { should be_true }
    end

    context "when the path does not contain a metadata.json or metadata.rb file" do
      before { FileUtils.rm_f(metadata_rb) && FileUtils.rm_f(metadata_json) }
      its(:cookbook?) { should be_false }
    end
  end

  describe "#cookbook_root" do
    let(:root_path) { fixtures_path.join("cookbooks", "example_cookbook") }
    let(:cookbook_path) { root_path }
    subject { Pathname.new(cookbook_path) }

    context "when in the root of a cookbook" do
      its(:cookbook_root) { should eql(root_path) }
    end

    context "when in the structure of a cookbook" do
      let(:cookbook_path) { root_path.join("recipes") }
      its(:cookbook_root) { should eql(root_path) }
    end

    context "when not within the structure of a cookbook" do
      let(:cookbook_path) { "/" }
      its(:cookbook_root) { should be_nil }
    end
  end
end
