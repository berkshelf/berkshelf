require 'spec_helper'

describe Berkshelf::SiteLocation do
  subject { described_class.new('artifact', '~> 1.0.0') }

  describe '#download' do
    pending
  end

  describe '#target_version' do
    pending
  end

  describe '#to_hash' do
    pending
  end

  describe '#to_s' do
    before { subject.stub(:api_uri).and_return('http://cookbooks.example.com') }

    it 'includes the berkshelf path' do
      expect(subject.to_s).to eq("#<#{described_class} #{subject.api_uri}>")
    end
  end

  describe '#inspect' do
    before { subject.stub(:api_uri).and_return('http://cookbooks.example.com') }

    it 'includes the cookbooks directory' do
      expect(subject.inspect).to eq("#<#{described_class} #{subject.api_uri}, name: #{subject.name}, version_constraint: #{subject.version_constraint}>")
    end
  end
end
