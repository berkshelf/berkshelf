require 'spec_helper'

describe Berkshelf::Downloader do
  let(:berksfile) { double('berksfile') }
  subject { described_class.new(berksfile) }

  describe "#download" do
    skip
  end

  describe "#try_download" do
    let(:remote_cookbook) { double('remote-cookbook') }
    let(:source) do
      source = double('source')
      allow(source).to receive(:cookbook) { remote_cookbook }
      source
    end
    let(:name) { "fake" }
    let(:version) { "1.0.0" }

    it "supports the 'opscode' location type" do
      allow(remote_cookbook).to receive(:location_type) { :opscode }
      allow(remote_cookbook).to receive(:location_path) { "http://api.opscode.com" }
      rest = double('community-rest')
      expect(Berkshelf::CommunityREST).to receive(:new).with("http://api.opscode.com") { rest }
      expect(rest).to receive(:download).with(name, version)
      subject.try_download(source, name, version)
    end

    it "supports the 'supermarket' location type" do
      allow(remote_cookbook).to receive(:location_type) { :supermarket }
      allow(remote_cookbook).to receive(:location_path) { "http://api.supermarket.com" }
      rest = double('community-rest')
      expect(Berkshelf::CommunityREST).to receive(:new).with("http://api.supermarket.com") { rest }
      expect(rest).to receive(:download).with(name, version)
      subject.try_download(source, name, version)
    end

    it "supports the 'file_store' location type" do
      skip
    end
  end
end
