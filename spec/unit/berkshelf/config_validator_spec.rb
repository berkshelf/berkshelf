require 'spec_helper'

describe Berkshelf::ConfigValidator do
  let(:config) { Berkshelf::Config.from_json json }
  let(:config_validator) { klass.new Hash.new }
  let(:json) { '{}' }
  let(:klass) { described_class }
  let(:structure) { Hash.new }

  before :each do
    config_validator.stub structure: structure
  end

  describe "#validate" do
    subject { config_validator.validate config }

    it { should be_true }

    context "with a top-level key" do
      let(:json) { '{ "a": 1 }' }
      let(:structure) { { a: Object } }

      it { should be_true }
    end

    context "with a nested key" do
      let(:json) { '{ "a": { "b": 1 } }' }
      let(:structure) { { a: { b: Object } } }

      it { should be_true }
    end

    context "with a top-level nonsense key" do
      let(:json) { '{ "nonsense": null }' }
      let(:structure) { { a: Object } }

      it { should be_false }
    end

    context "with a nested nonsense key" do
      let(:json) { '{ "a": { "nonsense": 1 } }' }
      let(:structure) { { a: { b: Object } } }

      it { should be_false }
    end

    context "with a top-level key that doesn't match the expected type" do
      let(:json) { '{ "a": 1 }' }
      let(:structure) { { a: String } }

      it { should be_false }
    end

    context "with a nested key that doesn't match the expected type" do
      let(:json) { '{ "a": { "b": 1 } }' }
      let(:structure) { { a: { b: String } } }

      it { should be_false }
    end
  end
end
