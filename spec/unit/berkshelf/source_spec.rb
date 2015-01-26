require 'spec_helper'

module Berkshelf
  describe Source do
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

    describe '.default?' do
      it 'returns true when the source is the default' do
        instance = described_class.new(Berksfile::DEFAULT_API_URL)
        expect(instance).to be_default
      end

      it 'returns true when the scheme is different' do
        instance = described_class.new('http://supermarket.chef.io')
        expect(instance).to be_default
      end

      it 'returns false when the source is not the default' do
        instance = described_class.new('http://localhost:8080')
        expect(instance).to_not be_default
      end
    end

    describe "#search" do
      let (:cookbooks) {[ 
        APIClient::RemoteCookbook.new("cb1","1.0.8"),
        APIClient::RemoteCookbook.new("cb1","1.0.22")
      ]}

      before do
        allow_any_instance_of(APIClient::Connection).to receive(:universe).and_return(cookbooks)
      end

      it "returns the latest version" do
        instance = described_class.new(Berksfile::DEFAULT_API_URL)
        expect(instance.search("cb1")).to eq [cookbooks[1]]
      end
    end
  end
end
