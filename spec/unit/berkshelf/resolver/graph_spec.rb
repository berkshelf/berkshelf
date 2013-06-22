require 'spec_helper'

describe Berkshelf::Resolver::Graph do
  subject { described_class.new }

  describe "#populate" do
    let(:sources) { "http://localhost:26200" }

    before do
      berks_dependency("ruby", "1.0.0", dependencies: { "elixir" => ">= 0.1.0" })
      berks_dependency("ruby", "2.0.0")
      berks_dependency("elixir", "1.0.0")
    end

    it "adds each dependency to the graph" do
      subject.populate(sources)
      expect(subject.artifacts).to have(3).items
    end

    it "adds the dependencies of each dependency to the graph" do
      subject.populate(sources)
      expect(subject.artifacts("ruby", "1.0.0").dependencies).to have(1).item
    end
  end

  describe "#universe" do
    let(:sources) { "http://localhost:26200" }

    before do
      berks_dependency("ruby", "1.0.0")
      berks_dependency("elixir", "1.0.0")
    end

    it "returns a Hash" do
      expect(subject.universe(sources)).to be_a(Hash)
    end

    it "contains the entire universe of dependencies" do
      expect(subject.universe(sources)).to have(2).items
    end
  end
end
