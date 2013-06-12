require 'spec_helper'

describe Berkshelf::Location do
  # Since this is a module, we need to test the implementation via a class
  let(:klass) { Class.new { include Berkshelf::Location } }

  describe '.set_location_key' do
    before do
      @original = Berkshelf::CookbookSource.class_variable_get :@@location_keys
      Berkshelf::CookbookSource.class_variable_set :@@location_keys, {}
    end

    after do
      Berkshelf::CookbookSource.class_variable_set :@@location_keys, @original
    end

    it 'adds the given location key CookbookSource.location_keys' do
      klass.set_location_key(:reset)

      expect(Berkshelf::CookbookSource.location_keys).to have(1).item
      expect(Berkshelf::CookbookSource.location_keys).to include(:reset)
      expect(Berkshelf::CookbookSource.location_keys[:reset]).to eq(klass)
    end
  end

  describe '.location_key' do
    before do
      @original = Berkshelf::CookbookSource.class_variable_get :@@location_keys
      Berkshelf::CookbookSource.class_variable_set :@@location_keys, {}
    end

    after do
      Berkshelf::CookbookSource.class_variable_set :@@location_keys, @original
    end

    it "returns the class' registered location key" do
      klass.set_location_key(:reset)
      expect(klass.location_key).to eq(:reset)
    end
  end

  describe '.set_valid_options' do
    before do
      @original = Berkshelf::CookbookSource.class_variable_get :@@valid_options
      Berkshelf::CookbookSource.class_variable_set :@@valid_options, []
    end

    after do
      Berkshelf::CookbookSource.class_variable_set :@@valid_options, @original
    end

    it 'adds the given symbol to the list of valid options on CookbookSource' do
      klass.set_valid_options(:mundo)

      expect(Berkshelf::CookbookSource.valid_options).to have(1).item
      expect(Berkshelf::CookbookSource.valid_options).to include(:mundo)
    end

    it 'adds parameters to the list of valid options on the CookbookSource' do
      klass.set_valid_options(:riot, :arenanet)

      expect(Berkshelf::CookbookSource.valid_options).to have(2).items
      expect(Berkshelf::CookbookSource.valid_options).to include(:riot)
      expect(Berkshelf::CookbookSource.valid_options).to include(:arenanet)
    end
  end

  describe '.solve_for_constraint' do
    let(:constraint) { '~> 0.101.2' }
    let(:versions) do
      {
        '0.101.2' => 'http://cookbooks.opscode.com/api/v1/cookbooks/nginx/versions/0_101_2',
        '0.101.0' => 'http://cookbooks.opscode.com/api/v1/cookbooks/nginx/versions/0_101_0',
        '0.100.2' => 'http://cookbooks.opscode.com/api/v1/cookbooks/nginx/versions/0_100_2',
        '0.100.0' => 'http://cookbooks.opscode.com/api/v1/cookbooks/nginx/versions/0_100_0'
      }
    end

    it 'returns an array with a string containing the version of the solution at index 0' do
      result = klass.solve_for_constraint(constraint, versions)
      expect(result[0]).to eq('0.101.2')
    end

    it 'returns an array containing a URI at index 0' do
      result = klass.solve_for_constraint(constraint, versions)
      expect(result[1]).to match(URI.regexp)
    end

    it 'returns the best match for the constraint and versions given' do
      expect(klass.solve_for_constraint(constraint, versions)[0].to_s).to eql('0.101.2')
    end

    context 'given a solution can not be found for constraint' do
      it 'returns nil' do
        result = klass.solve_for_constraint(Solve::Constraint.new('>= 1.0'), versions)
        expect(result).to be_nil
      end
    end
  end

  describe ';init' do
    let(:name) { 'artifact' }
    let(:constraint) { double('constraint') }

    it 'returns an instance of SiteLocation given a site: option key' do
      result = Berkshelf::Location.init(name, constraint, site: 'http://site/value')
      expect(result).to be_a(Berkshelf::SiteLocation)
    end

    it 'returns an instance of PathLocation given a path: option key' do
      result = Berkshelf::Location.init(name, constraint, path: '/Users/reset/code')
      expect(result).to be_a(Berkshelf::PathLocation)
    end

    it 'returns an instance of GitLocation given a git: option key' do
      result = Berkshelf::Location.init(name, constraint, git: 'git://github.com/something.git')
      expect(result).to be_a(Berkshelf::GitLocation)
    end

    it 'returns an instance of SiteLocation when no option key is given that matches a registered location_key' do
      result = Berkshelf::Location.init(name, constraint)
      expect(result).to be_a(Berkshelf::SiteLocation)
    end

    context 'given two location_keys' do
      it 'raises an InternalError' do
        expect {
          Berkshelf::Location.init(name, constraint, git: :value, path: :value)
        }.to raise_error(Berkshelf::InternalError)
      end
    end
  end



  let(:name) { 'nginx' }
  let(:constraint) { double('constraint') }

  subject do
    Class.new { include Berkshelf::Location }.new(name, constraint)
  end

  describe '#download' do
    it 'raises a AbstractFunction if not defined' do
      expect {
        subject.download(double('destination'))
      }.to raise_error(Berkshelf::AbstractFunction)
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
        msg = Berkshelf::MismatchedCookbookName.new(subject, cached).to_s

        Berkshelf.ui.should_receive(:warn).with(msg)
        subject.validate_cached(cached)
      end
    end
  end
end
