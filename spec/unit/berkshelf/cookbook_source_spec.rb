require 'spec_helper'

module Berkshelf
  describe CookbookSource do
    let(:cookbook_name) { 'nginx' }
    subject { CookbookSource.new(cookbook_name) }

    #
    # Class Methods
    #
    describe '.initialize' do
      context 'with no location key or constraints (i.e. :git, :path, :site)' do
        let(:source) { Berkshelf::CookbookSource.new(cookbook_name) }

        it 'sets a default value for location' do
          expect(source.location).to be_a(SiteLocation)
          expect(source.location.api_uri).to eq('http://cookbooks.opscode.com/api/v1/cookbooks')
        end

        it 'returns a Solve::Constraint for the version_constraint' do
          expect(source.version_constraint).to be_a(Solve::Constraint)
        end

        it 'returns a wildcard match for any version' do
          expect(source.version_constraint.to_s).to eq('>= 0.0.0')
        end
      end

      context 'with a value for constraint' do
        let(:source) { Berkshelf::CookbookSource.new(cookbook_name, constraint: '~> 1.0.84') }

        it 'returns a Solve::Constraint for the version_constraint' do
          expect(source.version_constraint).to be_a(Solve::Constraint)
        end

        it 'returns the correct version' do
          expect(source.version_constraint.to_s).to eq('~> 1.0.84')
        end
      end

      context 'with :git specified' do
        let(:url) { 'git://url_to_git' }
        let(:source) { Berkshelf::CookbookSource.new(cookbook_name, git: url) }

        it 'initializes a GitLocation for location' do
          expect(source.location).to be_a(GitLocation)
        end

        it 'points to the given Git URL' do
          expect(source.location.uri).to eq(url)
        end
      end

      context 'with a :path specified' do
        context 'when :path contains a cookbook' do
          let(:path) { fixtures_path.join('cookbooks', 'example_cookbook').to_s }
          let(:source) { Berkshelf::CookbookSource.new(cookbook_name, path: path) }

          it 'initializes a PathLocation for location' do
            expect(source.location).to be_a(PathLocation)
          end

          it 'points to the specified path' do
            expect(source.location.path).to eq(path)
          end
        end

        context 'when :path does not contain a cookbook' do
          let(:path) { '/does/not/exist' }

          it 'raises Berkshelf::CookbookNotFound' do
            expect {
              Berkshelf::CookbookSource.new(cookbook_name, path: path)
            }.to raise_error(Berkshelf::CookbookNotFound)
          end
        end

        context 'given an invalid option' do
          it 'raises BerkshelfError' do
            expect {
              Berkshelf::CookbookSource.new(cookbook_name, invalid_opt: 'thisisnotvalid')
            }.to raise_error(Berkshelf::BerkshelfError, "Invalid options for Cookbook Source: 'invalid_opt'.")
          end

          it 'raises BerkshelfError with a messaging containing all of the invalid options' do
            expect {
              Berkshelf::CookbookSource.new(cookbook_name, invalid_one: 'one', invalid_two: 'two')
            }.to raise_error(Berkshelf::BerkshelfError, "Invalid options for Cookbook Source: 'invalid_one', 'invalid_two'.")
          end
        end

        context 'with :site specified' do
          let(:url) { 'http://path_to_api/v1' }
          let(:source) { Berkshelf::CookbookSource.new(cookbook_name, site: url) }

          it 'initializes a SiteLocation for location' do
            expect(source.location).to be_a(SiteLocation)
          end

          it 'points to the specified URI' do
            expect(source.location.api_uri).to eql(url)
          end
        end

        context 'given multiple location options' do
          it 'raises with an Berkshelf::BerkshelfError' do
            expect {
              Berkshelf::CookbookSource.new(cookbook_name, site: "something", git: "something")
            }.to raise_error(Berkshelf::BerkshelfError)
          end
        end

        context 'given a :group containing a single group' do
          let(:group) { :production }
          let(:source) { Berkshelf::CookbookSource.new(cookbook_name, group: group) }

          it 'assigns the group to the groups attribute' do
            expect(source.groups).to include(group)
          end
        end

        context 'given a :group containing an array of groups' do
          let(:groups) { [ :development, :test ] }
          let(:source) { Berkshelf::CookbookSource.new(cookbook_name, group: groups) }

          it 'assigns all the groups to the group attribute' do
            expect(source.groups).to eq(groups)
          end
        end

        context 'given no :groups' do
          let(:source) { Berkshelf::CookbookSource.new(cookbook_name) }

          it 'assigns the default group' do
            expect(source.groups).to include(:default)
          end
        end
      end
    end

    describe '.add_valid_option' do
      before(:each) do
        @original = Berkshelf::CookbookSource.class_variable_get :@@valid_options
        Berkshelf::CookbookSource.class_variable_set :@@valid_options, []
      end

      after(:each) do
        Berkshelf::CookbookSource.class_variable_set :@@valid_options, @original
      end

      it 'adds an option to the list of valid options' do
        Berkshelf::CookbookSource.add_valid_option(:one)

        Berkshelf::CookbookSource.valid_options.should have(1).item
        Berkshelf::CookbookSource.valid_options.should include(:one)
      end

      it 'does not add duplicate options to the list of valid options' do
        Berkshelf::CookbookSource.add_valid_option(:one)
        Berkshelf::CookbookSource.add_valid_option(:one)

        Berkshelf::CookbookSource.valid_options.should have(1).item
        Berkshelf::CookbookSource.valid_options.should include(:one)
      end
    end

    describe '.add_location_key' do
      before(:each) do
        @original = Berkshelf::CookbookSource.class_variable_get :@@location_keys
        Berkshelf::CookbookSource.class_variable_set :@@location_keys, {}
      end

      after(:each) do
        Berkshelf::CookbookSource.class_variable_set :@@location_keys, @original
      end

      it "adds a location key and the associated class to the list of valid locations" do
        Berkshelf::CookbookSource.add_location_key(:git, Berkshelf::CookbookSource)

        Berkshelf::CookbookSource.location_keys.should have(1).item
        Berkshelf::CookbookSource.location_keys.should include(:git)
        Berkshelf::CookbookSource.location_keys[:git].should eql(Berkshelf::CookbookSource)
      end

      it "does not add duplicate location keys to the list of location keys" do
        2.times do
          Berkshelf::CookbookSource.add_location_key(:git, Berkshelf::CookbookSource)
        end

        Berkshelf::CookbookSource.location_keys.should have(1).item
        Berkshelf::CookbookSource.location_keys.should include(:git)
      end
    end

    #
    # Instance methods
    #
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

      it 'accepts multiple groups as an array' do
        subject.add_group ['baz', 'quux']
        expect(subject.groups).to eq([:default, :baz, :quux])
      end
    end

    describe '#downloaded?' do
      it 'returns true if #cached_cookbook is not nil' do
        subject.stub(:cached_cookbook) { double('cb') }
        expect(subject.downloaded?).to be_true
      end

      it 'returns false if self.cached_cookbook is nil' do
        subject.stub(:cached_cookbook) { nil }
        expect(subject.downloaded?).to be_false
      end
    end

    describe '#to_s' do
      it 'contains the name and constraint' do
        source = Berkshelf::CookbookSource.new('artifact', constraint: '= 0.10.0')
        expect(source.to_s).to eq('#<Berkshelf::CookbookSource: artifact (= 0.10.0)>')
      end

      context 'with a CookbookSource with an explicit location' do
        it 'contains the name and constraint' do
          source = Berkshelf::CookbookSource.new('artifact', constraint: '= 0.10.0', site: 'http://cookbooks.opscode.com/api/v1/cookbooks')
          expect(source.to_s).to eq("#<Berkshelf::CookbookSource: artifact (= 0.10.0)>")
        end
      end
    end

    describe '#inspect' do
      it 'contains the name, constraint, groups, and location' do
        source = Berkshelf::CookbookSource.new('artifact', constraint: '= 0.10.0')
        expect(source.inspect).to eq("#<Berkshelf::CookbookSource: artifact (= 0.10.0), groups: [:default], location: site: 'http://cookbooks.opscode.com/api/v1/cookbooks'>")
      end
    end

  end
end
