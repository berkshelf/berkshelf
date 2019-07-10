require "spec_helper"
require "chef/cookbook_manifest"

describe Berkshelf::RidleyCompat do
  let(:opts) { {} }

  subject { described_class.new(opts) }

  context "default" do
    it "has a cookbook version_class" do
      expect(subject.options).to have_key(:version_class)
      expect(subject.options[:version_class])
        .to eq(Chef::CookbookManifestVersions)
    end
  end
end
