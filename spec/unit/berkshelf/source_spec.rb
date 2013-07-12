require 'spec_helper'

describe Berkshelf::Source do
  describe "#universe"
  describe "#cookbook"
  describe "#versions"

  describe "#==" do
    it "is the same if the uri matches" do
      first = described_class.new("http://localhost:8080")
      other = described_class.new("http://localhost:8080")

      expect(first).to eq(other)
    end

    it "is not the same if the uri is different" do
      first = described_class.new("http://localhost:8089")
      other = described_class.new("http://localhost:8080")

      expect(first).to_not eq(other)
    end
  end
end
