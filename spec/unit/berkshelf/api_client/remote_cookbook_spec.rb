require 'spec_helper'

describe Berkshelf::APIClient::RemoteCookbook do
  let(:name) { "ruby" }
  let(:version) { "1.2.3" }
  let(:dependencies) { double('dependencies') }
  let(:platforms) { double('platforms') }
  let(:location_type) { "chef_server" }
  let(:location_path) { "http://localhost:8080" }

  let(:attributes) do
    { dependencies: dependencies, platforms: platforms, location_path: location_path, location_type: location_type }
  end

  subject { described_class.new(name, version, attributes) }

  its(:name) { should eql(name) }
  its(:version) { should eql(version) }
  its(:dependencies) { should eql(dependencies) }
  its(:platforms) { should eql(platforms) }
  its(:location_type) { should eql(:chef_server) }
  its(:location_path) { should eql(location_path) }
end
