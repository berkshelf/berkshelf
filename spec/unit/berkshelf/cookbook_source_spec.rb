require 'spec_helper'

describe Berkshelf::CookbookSource do
  let(:cookbook_name) { "nginx" }
  let(:berksfile) { double('berksfile', filepath: fixtures_path.join("Berksfile").to_s) }

  describe "ClassMethods" do
    subject { Berkshelf::CookbookSource }

    describe "::initialize" do
      context "given no location key (i.e. :git, :path, :site)" do
        let(:source) { subject.new(berksfile, cookbook_name) }

        it "sets a nil valie for location" do
          source.location.should be_nil
        end
      end

      context 'given no value for :locked_version' do
        let(:source) { subject.new(berksfile, cookbook_name) }

        it 'returns a wildcard match for any version' do
          expect(source.locked_version).to be_nil
        end
      end

      context 'given no value for :constraint' do
        let(:source) { subject.new(berksfile, cookbook_name) }

        it 'returns a wildcard match for any version' do
          expect(source.version_constraint.to_s).to eq('>= 0.0.0')
        end
      end

      context 'given a value for :constraint' do
        let(:source) { subject.new(berksfile, cookbook_name, constraint: '~> 1.0.84') }

        it 'returns a Solve::Constraint for the given version for version_constraint' do
          expect(source.version_constraint.to_s).to eq('~> 1.0.84')
        end
      end

      context "given a location key :git" do
        let(:url) { "git://url_to_git" }
        let(:source) { subject.new(berksfile, cookbook_name, git: url) }

        it "initializes a GitLocation for location" do
          source.location.should be_a(Berkshelf::GitLocation)
        end

        it "points to the given Git URL" do
          source.location.uri.should eql(url)
        end
      end

      context "given a location key :path" do
        context "given a value for path that contains a cookbook" do
          let(:path) { fixtures_path.join("cookbooks", "example_cookbook").to_s }

          it "initializes a PathLocation for location" do
            subject.new(berksfile, cookbook_name, path: path).location.should be_a(Berkshelf::PathLocation)
          end

          it "points to the specified path" do
            subject.new(berksfile, cookbook_name, path: path).location.path.should eql(path)
          end
        end

        context "given a value for path that does not contain a cookbook" do
          let(:path) { "/does/not/exist" }

          it "raises Berkshelf::CookbookNotFound" do
            lambda {
              subject.new(berksfile, cookbook_name, path: path)
            }.should raise_error(Berkshelf::CookbookNotFound)
          end
        end

        context "given an invalid option" do
          it "raises BerkshelfError with a friendly message" do
            lambda {
              subject.new(berksfile, cookbook_name, invalid_opt: "thisisnotvalid")
            }.should raise_error(Berkshelf::BerkshelfError, "Invalid options for Cookbook Source: 'invalid_opt'.")
          end

          it "raises BerkshelfError with a messaging containing all of the invalid options" do
            lambda {
              subject.new(berksfile, cookbook_name, invalid_one: "one", invalid_two: "two")
            }.should raise_error(Berkshelf::BerkshelfError, "Invalid options for Cookbook Source: 'invalid_one', 'invalid_two'.")
          end
        end

        describe "::add_valid_option" do
          before(:each) do
            @original = subject.class_variable_get :@@valid_options
            subject.class_variable_set :@@valid_options, []
          end

          after(:each) do
            subject.class_variable_set :@@valid_options, @original
          end

          it "adds an option to the list of valid options" do
            subject.add_valid_option(:one)

            subject.valid_options.should have(1).item
            subject.valid_options.should include(:one)
          end

          it "does not add duplicate options to the list of valid options" do
            subject.add_valid_option(:one)
            subject.add_valid_option(:one)

            subject.valid_options.should have(1).item
            subject.valid_options.should include(:one)
          end
        end

        describe "::add_location_key" do
          before(:each) do
            @original = subject.class_variable_get :@@location_keys
            subject.class_variable_set :@@location_keys, {}
          end

          after(:each) do
            subject.class_variable_set :@@location_keys, @original
          end

          it "adds a location key and the associated class to the list of valid locations" do
            subject.add_location_key(:git, subject.class)

            subject.location_keys.should have(1).item
            subject.location_keys.should include(:git)
            subject.location_keys[:git].should eql(subject.class)
          end

          it "does not add duplicate location keys to the list of location keys" do
            subject.add_location_key(:git, subject.class)
            subject.add_location_key(:git, subject.class)

            subject.location_keys.should have(1).item
            subject.location_keys.should include(:git)
          end
        end
      end

      context "given a location key :site" do
        let(:url) { "http://path_to_api/v1" }
        let(:source) { subject.new(berksfile, cookbook_name, site: url) }

        it "initializes a SiteLocation for location" do
          source.location.should be_a(Berkshelf::SiteLocation)
        end

        it "points to the specified URI" do
          source.location.api_uri.to_s.should eql(url)
        end
      end

      context "given multiple location options" do
        it "raises with an Berkshelf::BerkshelfError" do
          lambda {
            subject.new(berksfile, cookbook_name, site: "something", git: "something")
          }.should raise_error(Berkshelf::BerkshelfError)
        end
      end

      context "given a group option containing a single group" do
        let(:group) { :production }
        let(:source) { subject.new(berksfile, cookbook_name, group: group) }

        it "assigns the single group to the groups attribute" do
          source.groups.should include(group)
        end
      end

      context "given a group option containing an array of groups" do
        let(:groups) { [ :development, :test ] }
        let(:source) { subject.new(berksfile, cookbook_name, group: groups) }

        it "assigns all the groups to the group attribute" do
          source.groups.should eql(groups)
        end
      end

      context "given no group option" do
        let(:source) { subject.new(berksfile, cookbook_name) }

        it "should have the default group assigned" do
          source.groups.should include(:default)
        end
      end
    end
  end

  subject { Berkshelf::CookbookSource.new(berksfile, cookbook_name) }

  describe '#add_group' do
    it "should store strings as symbols" do
      subject.add_group "foo"
      subject.groups.should =~ [:default, :foo]
    end

    it "should not store duplicate groups" do
      subject.add_group "bar"
      subject.add_group "bar"
      subject.add_group :bar
      subject.groups.should =~ [:default, :bar]
    end

    it "should add multiple groups" do
      subject.add_group "baz", "quux"
      subject.groups.should =~ [:default, :baz, :quux]
    end

    it "should handle multiple groups as an array" do
      subject.add_group ["baz", "quux"]
      subject.groups.should =~ [:default, :baz, :quux]
    end
  end

  describe "#cached_and_location" do
    let(:options) { Hash.new }

    before do
      Berkshelf::CachedCookbook.stub(:from_path).and_return(double('cached_cookbook'))
    end

    context "when given a value for :path" do
      before do
        berksfile.stub(filepath: "/rspec/Berksfile")
        options[:path] = "cookbooks/whatever"
      end

      it "returns a PathLocation with a path relative to the Berksfile's filepath" do
        _, location = subject.cached_and_location(options)

        location.path.should eql("/rspec/cookbooks/whatever")
      end
    end
  end

  describe "#downloaded?" do
    it "returns true if self.cached_cookbook is not nil" do
      subject.stub(:cached_cookbook) { double('cb') }

      subject.downloaded?.should be_true
    end

    it "returns false if self.cached_cookbook is nil" do
      subject.stub(:cached_cookbook) { nil }

      subject.downloaded?.should be_false
    end
  end

  describe "#to_hash" do
    let(:hash) { subject.to_hash }

    it "does not include default values" do
      expect(hash).to_not have_key(:constraint)
      expect(hash).to_not have_key(:locked_version)
      expect(hash).to_not have_key(:site)
      expect(hash).to_not have_key(:git)
      expect(hash).to_not have_key(:ref)
      expect(hash).to_not have_key(:path)
    end

    it "includes the constraint" do
      subject.version_constraint = '~> 1.0.0'

      expect(hash).to have_key(:constraint)
      expect(hash[:constraint]).to eq('~> 1.0.0')
    end

    it "includes the locked version" do
      subject.cached_cookbook = double('cached', version: '1.2.3')

      expect(hash).to have_key(:locked_version)
      expect(hash[:locked_version]).to eq('1.2.3')
    end

    it "does not include the site if it's the default" do
      location = double('site', site: Berkshelf::CommunityREST::V1_API)
      location.stub(:kind_of?).with(Berkshelf::SiteLocation).and_return(true)
      location.stub(:kind_of?).with(Berkshelf::GitLocation).and_return(false)
      subject.stub(:location).and_return(location)

      expect(hash).to_not have_key(:site)
    end

    it "includes the site" do
      location = double('site', site: 'www.example.com')
      location.stub(:kind_of?).with(Berkshelf::SiteLocation).and_return(true)
      location.stub(:kind_of?).with(Berkshelf::GitLocation).and_return(false)
      subject.stub(:location).and_return(location)

      expect(hash).to have_key(:site)
      expect(hash[:site]).to eq('www.example.com')
    end

    it "includes the git url and ref" do
      location = double('git', uri: 'git://github.com/foo/bar.git', ref: 'abcd1234')
      location.stub(:kind_of?).with(Berkshelf::SiteLocation).and_return(false)
      location.stub(:kind_of?).with(Berkshelf::GitLocation).and_return(true)
      subject.stub(:location).and_return(location)

      expect(hash).to have_key(:git)
      expect(hash[:git]).to eq('git://github.com/foo/bar.git')
      expect(hash).to have_key(:ref)
      expect(hash[:ref]).to eq('abcd1234')
    end

    it "includes a relative path" do
      subject.instance_variable_set(:@options, { path: '~/Development/foo' })

      expect(hash).to have_key(:path)
      expect(hash[:path]).to eq('~/Development/foo')
    end
  end

  describe "#to_s" do
    it "contains the name, constraint, and groups" do
      source = Berkshelf::CookbookSource.new(berksfile, "artifact", constraint: "= 0.10.0")

      source.to_s.should eql("#<Berkshelf::CookbookSource: artifact (= 0.10.0)>")
    end

    context "given a CookbookSource with an explicit location" do
      it "contains the name, constraint, groups, and location" do
        source = Berkshelf::CookbookSource.new(berksfile, "artifact", constraint: "= 0.10.0", site: "http://cookbooks.opscode.com/api/v1/cookbooks")

        source.to_s.should eql("#<Berkshelf::CookbookSource: artifact (= 0.10.0)>")
      end
    end
  end

  describe "#inspect" do
    it "contains the name, constraint, and groups" do
      source = Berkshelf::CookbookSource.new(berksfile, "artifact", constraint: "= 0.10.0")

      source.inspect.should eql("#<Berkshelf::CookbookSource: artifact (= 0.10.0), locked_version: nil, groups: [:default], location: default>")
    end

    context "given a CookbookSource with an explicit location" do
      it "contains the name, constraint, groups, and location" do
        source = Berkshelf::CookbookSource.new(berksfile, "artifact", constraint: "= 0.10.0", site: "http://cookbooks.opscode.com/api/v1/cookbooks")

        source.inspect.should eql("#<Berkshelf::CookbookSource: artifact (= 0.10.0), locked_version: nil, groups: [:default], location: site: 'http://cookbooks.opscode.com/api/v1/cookbooks'>")
      end
    end

    context "given an explicitly locked version" do
      it "includes the locked_version" do
        source = Berkshelf::CookbookSource.new(berksfile, "artifact", constraint: "= 0.10.0", site: "http://cookbooks.opscode.com/api/v1/cookbooks", locked_version: '1.2.3')

        source.inspect.should eql("#<Berkshelf::CookbookSource: artifact (= 0.10.0), locked_version: 1.2.3, groups: [:default], location: site: 'http://cookbooks.opscode.com/api/v1/cookbooks'>")
      end
    end
  end
end
