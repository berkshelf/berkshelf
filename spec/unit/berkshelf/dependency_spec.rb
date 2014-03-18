require 'spec_helper'

describe Berkshelf::Dependency do
  let(:cookbook_name) { 'nginx' }
  let(:berksfile) { double('berksfile', filepath: fixtures_path.join('Berksfile').to_s) }

  describe "ClassMethods" do
    describe "::new" do
      let(:source) { described_class.new(berksfile, cookbook_name) }

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
        let(:source) { described_class.new(berksfile, cookbook_name, constraint: '~> 1.0.84') }

        it 'returns a Solve::Constraint for the given version for version_constraint' do
          expect(source.version_constraint.to_s).to eq('~> 1.0.84')
        end
      end

      context 'given a location key :git' do
        let(:url) { 'git://url_to_git' }
        let(:source) { described_class.new(berksfile, cookbook_name, git: url) }

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
          let(:location) { described_class.new(berksfile, cookbook_name, path: path).location }

          it 'initializes a PathLocation for location' do
            expect(location).to be_a(Berkshelf::PathLocation)
          end

          it 'points to the specified path' do
            expect(location.path).to eq(path)
          end
        end

        context 'given a group option containing a single group' do
          let(:group) { :production }
          let(:source) { described_class.new(berksfile, cookbook_name, group: group) }

          it 'assigns the single group to the groups attribute' do
            expect(source.groups).to include(group)
          end
        end

        context 'given a group option containing an array of groups' do
          let(:groups) { [ :development, :test ] }
          let(:source) { described_class.new(berksfile, cookbook_name, group: groups) }

          it 'assigns all the groups to the group attribute' do
            expect(source.groups).to eq(groups)
          end
        end

        context 'given no group option' do
          let(:source) { described_class.new(berksfile, cookbook_name) }

          it 'has the default group assigned' do
            expect(source.groups).to include(:default)
          end
        end
      end
    end
  end

  subject { described_class.new(berksfile, cookbook_name) }

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

  describe "#cached_cookbook"
  describe "#download"

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
      subject.stub(locked_version: double('cached', to_s: '1.2.3'))

      expect(hash).to have_key(:locked_version)
      expect(hash[:locked_version]).to eq('1.2.3')
    end

    it 'includes the git url and ref' do
      location = double('git', uri: 'git://github.com/foo/bar.git', ref: 'abcd1234', rel: nil, download: nil)
      location.stub(:kind_of?).and_return(false)
      location.stub(:kind_of?).with(Berkshelf::GitLocation).and_return(true)
      subject.stub(:location).and_return(location)

      expect(hash).to have_key(:git)
      expect(hash[:git]).to eq('git://github.com/foo/bar.git')
      expect(hash).to have_key(:ref)
      expect(hash[:ref]).to eq('abcd1234')
    end

    it 'includes the git url and rel' do
      location = double('git', uri: 'git://github.com/foo/bar.git', ref: nil, rel: 'cookbooks/foo', download: nil)
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

  describe "#scm_location?" do
    let(:options) { Hash.new }
    subject { described_class.new(berksfile, cookbook_name, options).scm_location? }

    context "when the location is a GitLocation" do
      let(:options) { { git: "git@github.com:berkshelf/berkshelf.git" } }
      it { should be_true }
    end

    context "when the location is a GithubLocation" do
      let(:options) { { github: "berkshelf/berkshelf" } }
      it { should be_true }
    end

    context "when the location is a PathLocation" do
      let(:options) { { path: fixtures_path.join('cookbooks', 'example_cookbook') } }
      it { should be_false }
    end
  end

  describe "#path_location?" do
    let(:options) { Hash.new }
    subject { described_class.new(berksfile, cookbook_name, options).path_location? }

    context "when the location is a PathLocation" do
      let(:options) { { path: fixtures_path.join("cookbooks", "example_cookbook") } }
      it { should be_true }
    end

    context "when the location is not a PathLocation" do
      let(:options) { { github: "berkshelf/berkshelf" } }
      it { should be_false }
    end
  end
end
