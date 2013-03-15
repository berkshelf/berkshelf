require 'spec_helper'

describe Berkshelf::CommunityREST do
  let(:show_nginx_cookbook) do
    {
      "maintainer" => "opscode",
      "updated_at" => "2013-02-06T02:06:21Z",
      "category" => "Web Servers",
      "external_url" => "github.com/opscode-cookbooks/nginx",
      "latest_version" => "http://cookbooks.opscode.com/api/v1/cookbooks/nginx/versions/1_3_0",
      "created_at" => "2009-10-25T23:52:41Z",
      "average_rating" => 3.875,
      "name" => "nginx",
      "versions" => [
        "http://cookbooks.opscode.com/api/v1/cookbooks/nginx/versions/1_3_0",
        "http://cookbooks.opscode.com/api/v1/cookbooks/nginx/versions/1_2_0",
        "http://cookbooks.opscode.com/api/v1/cookbooks/nginx/versions/1_1_0",
        "http://cookbooks.opscode.com/api/v1/cookbooks/nginx/versions/1_0_0"
      ],
      "description" => "Installs and configures nginx"
    }
  end

  describe "ClassMethods" do
    subject { described_class }

    describe "::unpack" do
      pending
    end

    describe "::uri_escape_version" do
      pending
    end

    describe "::version_from_uri" do
      pending
    end
  end

  let(:api_uri) { described_class::V1_API }

  subject do
    described_class.new(api_uri)
  end

  describe "#download" do
    pending
  end

  describe "#find" do
    pending
  end

  describe "#latest_version" do
    it "returns the version number of the latest version of the cookbook" do
      stub_request(:get, File.join(api_uri, "nginx")).
        to_return(status: 200, body: show_nginx_cookbook)

      subject.latest_version("nginx").should eql("1.3.0")
    end

    it "raises a CookbookNotFound error on a 404 response" do
      stub_request(:get, File.join(api_uri, "not_existant")).
        to_return(status: 404, body: {})

      expect {
        subject.latest_version("not_existant")
      }.to raise_error(Berkshelf::CookbookNotFound)
    end

    it "raises a CommunitySiteError error on any non 200 or 404 response" do
      stub_request(:get, File.join(api_uri, "not_existant")).
        to_return(status: 500, body: {})

      expect {
        subject.latest_version("not_existant")
      }.to raise_error(Berkshelf::CommunitySiteError)
    end
  end

  describe "#versions" do
    it "returns an array containing an item for each version" do
      stub_request(:get, File.join(api_uri, "nginx")).
        to_return(status: 200, body: show_nginx_cookbook)

      subject.versions("nginx").should have(4).versions
    end

    it "raises a CookbookNotFound error on a 404 response" do
      stub_request(:get, File.join(api_uri, "not_existant")).
        to_return(status: 404, body: {})

      expect {
        subject.versions("not_existant")
      }.to raise_error(Berkshelf::CookbookNotFound)
    end

    it "raises a CommunitySiteError error on any non 200 or 404 response" do
      stub_request(:get, File.join(api_uri, "not_existant")).
        to_return(status: 500, body: {})

      expect {
        subject.versions("not_existant")
      }.to raise_error(Berkshelf::CommunitySiteError)
    end
  end

  describe "#satisfy" do
    it "returns the version number of the best solution" do
      stub_request(:get, File.join(api_uri, "nginx")).
        to_return(status: 200, body: show_nginx_cookbook)

      subject.satisfy("nginx", "= 1.1.0").should eql("1.1.0")
    end
  end

  describe "#stream" do
    pending
  end
end
