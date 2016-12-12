require "spec_helper"

describe Berkshelf::BerkshelfError do
  skip
end

describe Berkshelf::CommunitySiteError do
  let(:api_uri) { "https://infra.as.code" }
  let(:message) { "Cookbook name" }

  subject { described_class.new(api_uri, message) }

  it "includes the supplied uri in the error message" do
    expect(subject.message).to include api_uri
  end

  it "includes the supplied message in the error message" do
    expect(subject.message).to include message
  end
end
