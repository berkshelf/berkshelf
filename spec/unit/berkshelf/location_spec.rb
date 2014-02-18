require 'spec_helper'

describe Berkshelf::Location do
  describe "ClassMethods" do
    describe "::init" do
      let(:dependency) { double('dependency') }

      it 'returns an instance of PathLocation given a path: option key' do
        result = described_class.init(dependency, path: '/Users/reset/code')
        expect(result).to be_a(Berkshelf::PathLocation)
      end

      it 'returns an instance of GitLocation given a git: option key' do
        result = described_class.init(dependency, git: 'git://github.com/something.git')
        expect(result).to be_a(Berkshelf::GitLocation)
      end
    end
  end
end

describe Berkshelf::BaseLocation do
  let(:name) { "nginx" }
  let(:constraint) { double('constraint') }
  let(:dependency) { double('dependency', name: name, version_constraint: constraint) }
  subject { Class.new(Berkshelf::BaseLocation).new(dependency) }

  describe "#download" do
    let(:cached) { double('cached') }

    it "validates the returned cached cookbook" do
      subject.should_receive(:validate_cached).with(cached).and_return(true)
      subject.download(cached)
    end

    it "returns the cached cookbook if valid" do
      subject.stub(validate_cached: true)
      expect(subject.download(cached)).to eq(cached)
    end
  end

  describe '#validate_cached' do
    let(:cached) { double('cached-cb', cookbook_name: name, version: '0.1.0') }

    it 'raises a CookbookValidationFailure error if the version constraint does not satisfy the cached version' do
      constraint.should_receive(:satisfies?).with(cached.version).and_return(false)

      expect {
        subject.validate_cached(cached)
      }.to raise_error(Berkshelf::CookbookValidationFailure)
    end

    it 'returns true if cached_cookbooks satisfies the version constraint' do
      constraint.should_receive(:satisfies?).with(cached.version).and_return(true)
      expect(subject.validate_cached(cached)).to be_true
    end

    context "when the cached_cookbooks satisfies the version constraint" do
      it "returns true if the name of the cached_cookbook matches the name of the location" do
        constraint.should_receive(:satisfies?).with(cached.version).and_return(true)
        cached.stub(:name) { name }
        expect(subject.validate_cached(cached)).to be_true
      end

      it "warns about the MismatchedCookbookName if the cached_cookbook's name does not match the location's" do
        constraint.should_receive(:satisfies?).with(cached.version).and_return(true)
        cached.stub(:cookbook_name) { "artifact" }
        msg = Berkshelf::MismatchedCookbookName.new(dependency, cached).to_s

        Berkshelf.ui.should_receive(:warn).with(msg)
        subject.validate_cached(cached)
      end
    end
  end
end
