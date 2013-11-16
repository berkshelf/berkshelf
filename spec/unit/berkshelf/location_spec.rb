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

      context 'given two location_keys' do
        it 'raises an InternalError' do
          expect {
            described_class.init(dependency, git: :value, path: :value)
          }.to raise_error(Berkshelf::InternalError)
        end
      end
    end
  end
end

describe Berkshelf::Location::Base do
  describe "ClassMethods" do
    subject { Class.new(described_class) }

    describe "::set_location_key" do
      before do
        @original = Berkshelf::Dependency.class_variable_get :@@location_keys
        Berkshelf::Dependency.class_variable_set :@@location_keys, {}
      end

      after do
        Berkshelf::Dependency.class_variable_set :@@location_keys, @original
      end

      it 'adds the given location key Berkshelf::Dependency.location_keys' do
        subject.set_location_key(:reset)

        expect(Berkshelf::Dependency.location_keys).to have(1).item
        expect(Berkshelf::Dependency.location_keys).to include(:reset)
        expect(Berkshelf::Dependency.location_keys[:reset]).to eq(subject)
      end
    end

    describe "::location_key" do
      before do
        @original = Berkshelf::Dependency.class_variable_get :@@location_keys
        Berkshelf::Dependency.class_variable_set :@@location_keys, {}
      end

      after do
        Berkshelf::Dependency.class_variable_set :@@location_keys, @original
      end

      it "returns the class' registered location key" do
        subject.set_location_key(:reset)
        expect(subject.location_key).to eq(:reset)
      end
    end

    describe "::set_valid_options" do
      before do
        @original = Berkshelf::Dependency.class_variable_get :@@valid_options
        Berkshelf::Dependency.class_variable_set :@@valid_options, []
      end

      after do
        Berkshelf::Dependency.class_variable_set :@@valid_options, @original
      end

      it 'adds the given symbol to the list of valid options on Berkshelf::Dependency' do
        subject.set_valid_options(:mundo)

        expect(Berkshelf::Dependency.valid_options).to have(1).item
        expect(Berkshelf::Dependency.valid_options).to include(:mundo)
      end

      it 'adds parameters to the list of valid options on the Berkshelf::Dependency' do
        subject.set_valid_options(:riot, :arenanet)

        expect(Berkshelf::Dependency.valid_options).to have(2).items
        expect(Berkshelf::Dependency.valid_options).to include(:riot)
        expect(Berkshelf::Dependency.valid_options).to include(:arenanet)
      end
    end
  end

  let(:name) { "nginx" }
  let(:constraint) { double('constraint') }
  let(:dependency) { double('dependency', name: name, version_constraint: constraint) }
  subject { Class.new(Berkshelf::Location::Base).new(dependency) }

  describe "#download" do
    context "when #do_download is not defined" do
      it "raises a AbstractFunction" do
        expect { subject.download }.to raise_error(Berkshelf::AbstractFunction)
      end
    end

    context "when #do_download is defined" do
      let(:cached) { double('cached') }
      before { subject.stub(do_download: cached) }

      it "validates the returned cached cookbook" do
        subject.should_receive(:validate_cached).with(cached).and_return(true)
        subject.download
      end

      it "returns the cached cookbook if valid" do
        subject.stub(validate_cached: true)

        expect(subject.download).to eq(cached)
      end
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

        Berkshelf.ui.should_receive(:alert_warning).with(msg)
        subject.validate_cached(cached)
      end
    end
  end
end
