require 'spec_helper'

describe Berkshelf::CookbookSource do
  let(:cookbook_name) { 'nginx' }
  let(:berksfile) { double('berksfile', filepath: fixtures_path.join('Berksfile').to_s) }

  describe '.initialize' do
    let(:source) { Berkshelf::CookbookSource.new(berksfile, cookbook_name) }

    context 'given no location key (i.e. :git, :path, :site)' do
      it 'sets a nil valie for location' do
        expect(source.location).to be_nil
      end
    end

    context 'given no value for :locked_version' do
      it 'returns a wildcard match for any version' do
        expect(source.locked_version).to be_nil
      end
    end

    context 'given no value for :constraint' do
      it 'returns a wildcard match for any version' do
        expect(source.version_constraint.to_s).to eq('>= 0.0.0')
      end
    end

    context 'given a value for :constraint' do
      let(:source) { Berkshelf::CookbookSource.new(berksfile, cookbook_name, constraint: '~> 1.0.84') }

      it 'returns a Solve::Constraint for the given version for version_constraint' do
        expect(source.version_constraint.to_s).to eq('~> 1.0.84')
      end
    end

    context 'given a location key :git' do
      let(:url) { 'git://url_to_git' }
      let(:source) { Berkshelf::CookbookSource.new(berksfile, cookbook_name, git: url) }

      it 'initializes a GitLocation for location' do
        expect(source.location).to be_a(Berkshelf::GitLocation)
      end

      it 'points to the given Git URL' do
        expect(source.location.uri).to eq(url)
      end
    end

    context 'given a location key :path' do
      context 'given a value for path that contains a cookbook' do
        let(:path) { fixtures_path.join('cookbooks', 'example_cookbook').to_s }
        let(:location) { Berkshelf::CookbookSource.new(berksfile, cookbook_name, path: path).location }

        it 'initializes a PathLocation for location' do
          expect(location).to be_a(Berkshelf::PathLocation)
        end

        it 'points to the specified path' do
          expect(location.path).to eq(path)
        end
      end

      context 'given a value for path that does not contain a cookbook' do
        let(:path) { '/does/not/exist' }

        it 'raises Berkshelf::CookbookNotFound' do
          expect {
            Berkshelf::CookbookSource.new(berksfile, cookbook_name, path: path)
          }.to raise_error(Berkshelf::CookbookNotFound)
        end
      end

      context 'given an invalid option' do
        it 'raises BerkshelfError with a friendly message' do
          expect {
            Berkshelf::CookbookSource.new(berksfile, cookbook_name, invalid_opt: 'thisisnotvalid')
          }.to raise_error(Berkshelf::BerkshelfError, "Invalid options for Cookbook Source: 'invalid_opt'.")
        end

        it 'raises BerkshelfError with a messaging containing all of the invalid options' do
          expect {
            Berkshelf::CookbookSource.new(berksfile, cookbook_name, invalid_one: 'one', invalid_two: 'two')
          }.to raise_error(Berkshelf::BerkshelfError, "Invalid options for Cookbook Source: 'invalid_one', 'invalid_two'.")
        end
      end
    end
  end

  describe '.add_valid_option' do
    before do
      @original = Berkshelf::CookbookSource.class_variable_get :@@valid_options
      Berkshelf::CookbookSource.class_variable_set :@@valid_options, []
    end

    after do
      Berkshelf::CookbookSource.class_variable_set :@@valid_options, @original
    end

    it 'adds an option to the list of valid options' do
      Berkshelf::CookbookSource.add_valid_option(:one)

      expect(Berkshelf::CookbookSource.valid_options).to have(1).item
      expect(Berkshelf::CookbookSource.valid_options).to include(:one)
    end

    it 'does not add duplicate options to the list of valid options' do
      Berkshelf::CookbookSource.add_valid_option(:one)
      Berkshelf::CookbookSource.add_valid_option(:one)

      expect(Berkshelf::CookbookSource.valid_options).to have(1).item
    end
  end

  describe '.add_location_key' do
    before do
      @original = Berkshelf::CookbookSource.class_variable_get :@@location_keys
      Berkshelf::CookbookSource.class_variable_set :@@location_keys, {}
    end

    after do
      Berkshelf::CookbookSource.class_variable_set :@@location_keys, @original
    end

    it 'adds a location key and the associated class to the list of valid locations' do
      Berkshelf::CookbookSource.add_location_key(:git, Berkshelf::CookbookSource)

      expect(Berkshelf::CookbookSource.location_keys).to have(1).item
      expect(Berkshelf::CookbookSource.location_keys).to include(:git)
      expect(Berkshelf::CookbookSource.location_keys[:git]).to eq(Berkshelf::CookbookSource)
    end

    it 'does not add duplicate location keys to the list of location keys' do
      Berkshelf::CookbookSource.add_location_key(:git, Berkshelf::CookbookSource)
      Berkshelf::CookbookSource.add_location_key(:git, Berkshelf::CookbookSource)

      expect(Berkshelf::CookbookSource.location_keys).to have(1).item
      expect(Berkshelf::CookbookSource.location_keys).to include(:git)
    end

    context 'given a location key :site' do
      let(:url) { 'http://path_to_api/v1' }
      let(:source) { Berkshelf::CookbookSource.new(berksfile, cookbook_name, site: url) }

      before do
        Berkshelf::CookbookSource.add_location_key(:site, Berkshelf::SiteLocation)
      end

      it 'initializes a SiteLocation for location' do
        expect(source.location).to be_a(Berkshelf::SiteLocation)
      end

      it 'points to the specified URI' do
        expect(source.location.api_uri.to_s).to eq(url)
      end
    end

    context 'given multiple location options' do
      it 'raises with an Berkshelf::BerkshelfError' do
        expect {
          Berkshelf::CookbookSource.new(berksfile, cookbook_name, site: 'something', git: 'something')
        }.to raise_error(Berkshelf::BerkshelfError)
      end
    end

    context 'given a group option containing a single group' do
      let(:group) { :production }
      let(:source) { Berkshelf::CookbookSource.new(berksfile, cookbook_name, group: group) }

      it 'assigns the single group to the groups attribute' do
        expect(source.groups).to include(group)
      end
    end

    context 'given a group option containing an array of groups' do
      let(:groups) { [ :development, :test ] }
      let(:source) { Berkshelf::CookbookSource.new(berksfile, cookbook_name, group: groups) }

      it 'assigns all the groups to the group attribute' do
        expect(source.groups).to eq(groups)
      end
    end

    context 'given no group option' do
      let(:source) { Berkshelf::CookbookSource.new(berksfile, cookbook_name) }

      it 'has the default group assigned' do
        expect(source.groups).to include(:default)
      end
    end
  end



  subject { Berkshelf::CookbookSource.new(berksfile, cookbook_name) }

  describe '#add_group' do
    it 'stores strings as symbols' do
      subject.add_group 'foo'
      expect(subject.groups).to eq([:default, :foo])
    end

    it 'does not store duplicate groups' do
      subject.add_group 'bar'
      subject.add_group 'bar'
      subject.add_group :bar
      expect(subject.groups).to eq([:default, :bar])
    end

    it 'adds multiple groups' do
      subject.add_group 'baz', 'quux'
      expect(subject.groups).to eq([:default, :baz, :quux])
    end

    it 'handles multiple groups as an array' do
      subject.add_group ['baz', 'quux']
      expect(subject.groups).to eq([:default, :baz, :quux])
    end
  end

  describe '#cached_and_location' do
    let(:options) { Hash.new }

    before do
      Berkshelf::CachedCookbook.stub(:from_path).and_return(double('cached_cookbook'))
    end

    context 'when given a value for :path' do
      before do
        berksfile.stub(filepath: '/rspec/Berksfile')
        options[:path] = 'cookbooks/whatever'
      end

      it 'returns a PathLocation with a path relative to the Berksfile.filepath' do
        _, location = subject.cached_and_location(options)

        expect(location.path).to eq('cookbooks/whatever')
        expect(location.relative_path(berksfile)).to eq('../cookbooks/whatever')
      end
    end
  end

  describe '#downloaded?' do
    it 'returns true if self.cached_cookbook is not nil' do
      subject.stub(:cached_cookbook) { double('cb') }
      expect(subject.downloaded?).to be_true
    end

    it 'returns false if self.cached_cookbook is nil' do
      subject.stub(:cached_cookbook) { nil }
      expect(subject.downloaded?).to be_false
    end
  end

  describe '#to_hash' do
    let(:hash) { subject.to_hash }

    it 'does not include default values' do
      [:constraint, :locked_version, :site, :git, :ref, :path].each do |key|
        expect(hash).to_not have_key(key)
      end
    end

    it 'includes the locked version' do
      subject.cached_cookbook = double('cached', version: '1.2.3')

      expect(hash).to have_key(:locked_version)
      expect(hash[:locked_version]).to eq('1.2.3')
    end

    it 'does not include the site if it is the default' do
      location = double('site', api_uri: Berkshelf::CommunityREST::V1_API)
      location.stub(:kind_of?).and_return(false)
      location.stub(:kind_of?).with(Berkshelf::SiteLocation).and_return(true)
      subject.stub(:location).and_return(location)

      expect(hash).to_not have_key(:site)
    end

    it 'includes the site' do
      location = double('site', api_uri: 'www.example.com')
      location.stub(:kind_of?).and_return(false)
      location.stub(:kind_of?).with(Berkshelf::SiteLocation).and_return(true)
      subject.stub(:location).and_return(location)

      expect(hash).to have_key(:site)
      expect(hash[:site]).to eq('www.example.com')
    end

    it 'includes the git url and ref' do
      location = double('git', uri: 'git://github.com/foo/bar.git', ref: 'abcd1234', rel: nil)
      location.stub(:kind_of?).and_return(false)
      location.stub(:kind_of?).with(Berkshelf::GitLocation).and_return(true)
      subject.stub(:location).and_return(location)

      expect(hash).to have_key(:git)
      expect(hash[:git]).to eq('git://github.com/foo/bar.git')
      expect(hash).to have_key(:ref)
      expect(hash[:ref]).to eq('abcd1234')
    end

    it 'includes the git url and rel' do
      location = double('git', uri: 'git://github.com/foo/bar.git', ref: nil, rel: 'cookbooks/foo')
      location.stub(:kind_of?).and_return(false)
      location.stub(:kind_of?).with(Berkshelf::GitLocation).and_return(true)
      subject.stub(:location).and_return(location)

      expect(hash).to have_key(:git)
      expect(hash[:git]).to eq('git://github.com/foo/bar.git')
      expect(hash).to have_key(:rel)
      expect(hash[:rel]).to eq('cookbooks/foo')
    end

    it 'includes a relative path' do
      location = double('path', relative_path: '../dev/foo')
      location.stub(:kind_of?).and_return(false)
      location.stub(:kind_of?).with(Berkshelf::PathLocation).and_return(true)
      subject.stub(:location).and_return(location)

      expect(hash).to have_key(:path)
      expect(hash[:path]).to eq('../dev/foo')
    end
  end

  describe '#to_s' do
    it 'contains the name, constraint, and groups' do
      source = Berkshelf::CookbookSource.new(berksfile, 'artifact', constraint: '= 0.10.0')
      expect(source.to_s).to eq('#<Berkshelf::CookbookSource: artifact (= 0.10.0)>')
    end

    context 'given a CookbookSource with an explicit location' do
      it 'contains the name, constraint, groups, and location' do
        source = Berkshelf::CookbookSource.new(berksfile, 'artifact', constraint: '= 0.10.0', site: 'http://cookbooks.opscode.com/api/v1/cookbooks')
        expect(source.to_s).to eq('#<Berkshelf::CookbookSource: artifact (= 0.10.0)>')
      end
    end
  end

  describe '#inspect' do
    it 'contains the name, constraint, and groups' do
      source = Berkshelf::CookbookSource.new(berksfile, 'artifact', constraint: '= 0.10.0')
      expect(source.inspect).to eq('#<Berkshelf::CookbookSource: artifact (= 0.10.0), locked_version: nil, groups: [:default], location: default>')
    end

    context 'given a CookbookSource with an explicit location' do
      it 'contains the name, constraint, groups, and location' do
        source = Berkshelf::CookbookSource.new(berksfile, 'artifact', constraint: '= 0.10.0', site: 'http://cookbooks.opscode.com/api/v1/cookbooks')
        expect(source.inspect).to eq("#<Berkshelf::CookbookSource: artifact (= 0.10.0), locked_version: nil, groups: [:default], location: site: 'http://cookbooks.opscode.com/api/v1/cookbooks'>")
      end
    end

    context 'given an explicitly locked version' do
      it 'includes the locked_version' do
        source = Berkshelf::CookbookSource.new(berksfile, 'artifact', constraint: '= 0.10.0', site: 'http://cookbooks.opscode.com/api/v1/cookbooks', locked_version: '1.2.3')
        expect(source.inspect).to eq("#<Berkshelf::CookbookSource: artifact (= 0.10.0), locked_version: 1.2.3, groups: [:default], location: site: 'http://cookbooks.opscode.com/api/v1/cookbooks'>")
      end
    end
  end
end
