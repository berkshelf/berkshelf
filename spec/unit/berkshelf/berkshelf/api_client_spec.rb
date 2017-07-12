require 'spec_helper'

describe Berkshelf::APIClient do
  describe "::new" do
    it "returns an instance of Berkshelf::APIClient::Connection" do
      expect(described_class.new("http://localhost:26210")).to be_a(Berkshelf::APIClient::Connection)
    end
  end
end
