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

    it "returns an array of APIClient::RemoteCookbook" do
      expect(subject).to be_a(Array)

      subject.each do |remote|
        expect(remote).to be_a(Berkshelf::APIClient::RemoteCookbook)
      end
    end

    it "contains a item for each dependency" do
      expect(subject).to have(3).items
      expect(subject[0].name).to eql("ruby")
      expect(subject[0].version).to eql("1.2.3")
      expect(subject[1].name).to eql("ruby")
      expect(subject[1].version).to eql("2.0.0")
      expect(subject[2].name).to eql("elixir")
      expect(subject[2].version).to eql("1.0.0")
    end

    it "has the dependencies for each" do
      expect(subject[0].dependencies).to include("build-essential" => ">= 1.2.2")
      expect(subject[1].dependencies).to include("build-essential" => ">= 1.2.2")
      expect(subject[2].dependencies).to be_empty
    end

    it "has the platforms for each" do
      expect(subject[0].platforms).to be_empty
      expect(subject[1].platforms).to be_empty
      expect(subject[2].platforms).to include("CentOS" => "= 6.0.0")
    end

    it "has a location_path for each" do
      subject.each do |remote|
        expect(remote.location_path).to_not be_nil
      end
    end

    it "has a location_type for each" do
      subject.each do |remote|
        expect(remote.location_type).to_not be_nil
      end
    end
  end
end
