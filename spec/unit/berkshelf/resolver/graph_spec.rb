require "spec_helper"

describe Berkshelf::Resolver::Graph, :not_supported_on_windows do
  let(:berksfile) { double("Berksfile", filepath: "/test/Berksfile") }
  subject { described_class.new }

  describe "#populate" do
    let(:sources) { Berkshelf::Source.new(berksfile, "http://supermarket.getchef.com") }

    before do
      body_response = %q{{"ruby":{"1.0.0":{"endpoint_priority":0,"platforms":{},"dependencies":{"elixir":">= 0.1.0"},"location_type":"supermarket","location_path":"https://supermarket.getchef.com/"},"2.0.0":{"endpoint_priority":0,"platforms":{},"dependencies":{},"location_type":"supermarket","location_path":"https://supermarket.getchef.com/"}},"elixir":{"1.0.0":{"endpoint_priority":0,"platforms":{},"dependencies":{},"location_type":"supermarket","location_path":"https://supermarket.getchef.com/"}}}}
      stub_request(:get, "http://supermarket.getchef.com/universe")
        .to_return(status: 200, body: body_response, headers: { "Content-Type" => "application/json; charset=utf-8" })
    end

    it "adds each dependency to the graph" do
      subject.populate(sources)
      expect(subject.artifacts.size).to eq(3)
    end

    it "adds the dependencies of each dependency to the graph" do
      subject.populate(sources)
      expect(subject.artifact("ruby", "1.0.0").dependencies.size).to eq(1)
    end
  end

  describe "#universe" do
    let(:sources) { Berkshelf::Source.new(berksfile, "http://supermarket.getchef.com") }

    before do
      body_response = %q{{"ruby":{"1.0.0":{"endpoint_priority":0,"platforms":{},"dependencies":{},"location_type":"supermarket","location_path":"https://supermarket.getchef.com/"}},"elixir":{"1.0.0":{"endpoint_priority":0,"platforms":{},"dependencies":{},"location_type":"supermarket","location_path":"https://supermarket.getchef.com/"}}}}
      stub_request(:get, "http://supermarket.getchef.com/universe")
        .to_return(status: 200, body: body_response, headers: { "Content-Type" => "application/json; charset=utf-8" })
    end

    it "returns an array of APIClient::RemoteCookbook" do
      result = subject.universe(sources)
      expect(result).to be_a(Array)
      result.each { |remote| expect(remote).to be_a(Berkshelf::APIClient::RemoteCookbook) }
    end

    it "contains the entire universe of dependencies" do
      expect(subject.universe(sources).size).to eq(2)
    end
  end
end
