require 'spec_helper'

describe Berkshelf::APIClient do
  let(:instance) { described_class.new("http://localhost:26200") }

  describe "#universe" do
    before do
      berks_dependency("ruby", "1.2.3", dependencies: { "build-essential" => ">= 1.2.2" })
      berks_dependency("ruby", "2.0.0", dependencies: { "build-essential" => ">= 1.2.2" })
      berks_dependency("elixir", "1.0.0", platforms: { "CentOS" => "6.0" })
    end

    subject { instance.universe }

    it "returns a Hashie::Mash" do
      expect(subject).to be_a(Hashie::Mash)
    end

    it "contains a key for each dependency" do
      expect(subject.keys).to have(2).items
      expect(subject).to have_key("ruby")
      expect(subject).to have_key("elixir")
    end

    it "each key contains a key for each version" do
      expect(subject["ruby"]).to have(2).items
      expect(subject["ruby"]).to have_key("1.2.3")
      expect(subject["ruby"]).to have_key("2.0.0")
      expect(subject["elixir"]).to have(1).items
      expect(subject["elixir"]).to have_key("1.0.0")
    end

    it "each version has a key for dependencies" do
      expect(subject["ruby"]["1.2.3"]).to have_key(:dependencies)
      expect(subject["ruby"]["2.0.0"]).to have_key(:dependencies)
      expect(subject["elixir"]["1.0.0"]).to have_key(:dependencies)
    end

    it "each dependency key contains the dependencies of the cookbook" do
      expect(subject["ruby"]["1.2.3"]["dependencies"]).to include("build-essential" => ">= 1.2.2")
      expect(subject["ruby"]["2.0.0"]["dependencies"]).to include("build-essential" => ">= 1.2.2")
      expect(subject["elixir"]["1.0.0"]["dependencies"]).to be_empty
    end

    it "each version has a key for platforms" do
      expect(subject["ruby"]["1.2.3"]).to have_key(:platforms)
      expect(subject["ruby"]["2.0.0"]).to have_key(:platforms)
      expect(subject["elixir"]["1.0.0"]).to have_key(:platforms)
    end

    it "each platform key contains the supported platforms of the cookbook" do
      expect(subject["ruby"]["1.2.3"]["platforms"]).to be_empty
      expect(subject["ruby"]["2.0.0"]["platforms"]).to be_empty
      expect(subject["elixir"]["1.0.0"]["platforms"]).to include("CentOS" => "= 6.0.0")
    end
  end
end
