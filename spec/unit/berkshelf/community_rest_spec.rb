require "spec_helper"

describe Berkshelf::CommunityREST do
  describe "ClassMethods" do
    describe "::unpack" do
      let(:target) { "/foo/bar" }
      let(:destination) { "/destination/bar" }
      let(:file) { double("file") }
      let(:gzip_reader) { double("gzip_reader") }
      let(:archive) { double("mixlib_archive") }

      before do
        allow(File).to receive(:open).with(target, "rb").and_return(file)
        allow(archive).to receive(:extract).with(destination)
        allow(Mixlib::Archive).to receive(:new).with(target).and_return(archive)
      end

      it "unpacks the tar" do
        expect(::IO).to receive(:binread).with(target, 2).and_return([0x1F, 0x8B].pack("C*"))
        expect(Mixlib::Archive).to receive(:new).with(target).and_return(archive)
        expect(archive).to receive(:extract).with(destination)

        expect(Berkshelf::CommunityREST.unpack(target, destination)).to eq(destination)
      end
    end

    describe "::uri_escape_version" do
      it "returns a string" do
        expect(Berkshelf::CommunityREST.uri_escape_version(nil)).to be_a(String)
      end

      it "converts a version to it's underscored version" do
        expect(Berkshelf::CommunityREST.uri_escape_version("1.1.2")).to eq("1_1_2")
      end

      it "works when the version has more than three points" do
        expect(Berkshelf::CommunityREST.uri_escape_version("1.1.1.2")).to eq("1_1_1_2")
      end

      it "works when the version has less than three points" do
        expect(Berkshelf::CommunityREST.uri_escape_version("1.2")).to eq("1_2")
      end
    end

    describe "::version_from_uri" do
      it "returns a string" do
        expect(Berkshelf::CommunityREST.version_from_uri(nil)).to be_a(String)
      end

      it "extracts the version from the URL" do
        expect(Berkshelf::CommunityREST.version_from_uri("/api/v1/cookbooks/nginx/versions/1_1_2")).to eq("1.1.2")
      end

      it "works when the version has more than three points" do
        expect(Berkshelf::CommunityREST.version_from_uri("/api/v1/cookbooks/nginx/versions/1_1_1_2")).to eq("1.1.1.2")
      end

      it "works when the version has less than three points" do
        expect(Berkshelf::CommunityREST.version_from_uri("/api/v1/cookbooks/nginx/versions/1_2")).to eq("1.2")
      end
    end
  end

  let(:api_uri) { Berkshelf::CommunityREST::V1_API }
  subject { Berkshelf::CommunityREST.new(api_uri) }

  describe "#download" do
    let(:archive) { double("archive", path: "/foo/bar", unlink: true) }

    before do
      allow(subject).to receive(:stream).with(any_args).and_return(archive)
      allow(Berkshelf::CommunityREST).to receive(:unpack)
        .and_return("/some/path")
    end

    it "unpacks the archive" do
      stub_request(:get, "#{api_uri}/cookbooks/bacon/versions/1_0_0").to_return(
        status: 200,
        body: '{ "cookbook": "/path/to/cookbook", "version": "1.0.0" }',
        headers: { "Content-Type" => "application/json" }
      )

      expect(Berkshelf::CommunityREST).to receive(:unpack)
        .with("/foo/bar", String)
        .and_return("/foo/nginx")
        .once
      expect(archive).to receive(:unlink).once

      subject.download("bacon", "1.0.0")
    end
  end

  describe "#find" do
    it "returns the cookbook and version information" do
      stub_request(:get, "#{api_uri}/cookbooks/bacon/versions/1_0_0").to_return(
        status: 200,
        body: '{ "cookbook": "/path/to/cookbook", "version": "1.0.0" }',
        headers: { "Content-Type" => "application/json" }
      )

      result = subject.find("bacon", "1.0.0")

      expect(result["cookbook"]).to eq("/path/to/cookbook")
      expect(result["version"]).to eq("1.0.0")
    end

    it "raises a CookbookNotFound error on a 404 response for a non-existent cookbook" do
      stub_request(:get, "#{api_uri}/cookbooks/not_real/versions/1_0_0").to_return(
        status: 404,
        body: "Not Found"
      )

      expect do
        subject.find("not_real", "1.0.0")
      end.to raise_error(Berkshelf::CookbookNotFound)
    end

    it "raises a CommunitySiteError error on any non 200 or 404 response" do
      stub_request(:get, "#{api_uri}/cookbooks/not_real/versions/1_0_0").to_return(
        status: 500,
        body: nil
      )

      expect do
        subject.find("not_real", "1.0.0")
      end.to raise_error(Berkshelf::CommunitySiteError)
    end
  end

  describe "#latest_version" do
    it "returns the version number of the latest version of the cookbook" do
      stub_request(:get, "#{api_uri}/cookbooks/bacon").to_return(
        status: 200,
        body: '{ "latest_version": "1.0.0" }',
        headers: { "Content-Type" => "application/json" }
      )

      latest = subject.latest_version("bacon")
      expect(latest).to eq("1.0.0")
    end

    it "raises a CookbookNotFound error on a 404 response" do
      stub_request(:get, "#{api_uri}/cookbooks/not_real").to_return(
        status: 404,
        body: "Not Found"
      )

      expect do
        subject.latest_version("not_real")
      end.to raise_error(Berkshelf::CookbookNotFound)
    end

    it "raises a CommunitySiteError error on any non 200 or 404 response" do
      stub_request(:get, "#{api_uri}/cookbooks/not_real").to_return(
        status: 500,
        body: nil
      )

      expect do
        subject.latest_version("not_real")
      end.to raise_error(Berkshelf::CommunitySiteError)
    end
  end

  describe "#versions" do
    it "returns an array containing an item for each version" do
      stub_request(:get, "#{api_uri}/cookbooks/bacon").to_return(
        status: 200,
        body: '{ "versions": ["/bacon/versions/1_0_0", "/bacon/versions/2_0_0"] }',
        headers: { "Content-Type" => "application/json" }
      )

      versions = subject.versions("bacon")
      expect(versions.size).to eq(2)
    end

    it "raises a CookbookNotFound error on a 404 response" do
      stub_request(:get, "#{api_uri}/cookbooks/not_real").to_return(
        status: 404,
        body: "Not Found"
      )

      expect do
        subject.versions("not_real")
      end.to raise_error(Berkshelf::CookbookNotFound)
    end

    it "raises a CommunitySiteError error on any non 200 or 404 response" do
      stub_request(:get, "#{api_uri}/cookbooks/not_real").to_return(
        status: 500,
        body: nil
      )

      expect do
        subject.versions("not_real")
      end.to raise_error(Berkshelf::CommunitySiteError)
    end
  end

  describe "#satisfy" do
    it "returns the version number of the best solution" do
      stub_request(:get, "#{api_uri}/cookbooks/bacon").to_return(
        status: 200,
        body: '{ "versions": ["/bacon/versions/1_0_0", "/bacon/versions/2_0_0"] }',
        headers: { "Content-Type" => "application/json" }
      )

      result = subject.satisfy("bacon", "= 1.0.0")
      expect(result).to eq("1.0.0")
    end
  end

  describe "#stream" do
    skip
  end
end
