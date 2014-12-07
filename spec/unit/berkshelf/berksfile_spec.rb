require 'spec_helper'

describe Berkshelf::Berksfile do
  describe "ClassMethods" do
    describe '::from_file' do
      let(:content) do
        <<-EOF.strip
        cookbook 'ntp', '<= 1.0.0'
        cookbook 'mysql'
        cookbook 'nginx', '< 0.101.2'
        cookbook 'ssh_known_hosts2', :git => 'https://github.com/erikh/chef-ssh_known_hosts2.git'
        EOF
      end
      let(:berksfile) { tmp_path.join('Berksfile') }

      before { File.open(berksfile, 'w+') { |f| f.write(content) } }
      subject(:from_file) { described_class.from_file(berksfile) }

      it "reads the content of the Berksfile and binds them to a new instance" do
        %w(ntp mysql nginx ssh_known_hosts2).each do |name|
          expect(subject).to have_dependency(name)
        end
      end

      it "returns an instance of Berkshelf::Berksfile" do
        expect(subject).to be_a(described_class)
      end

      context 'when Berksfile does not exist at given path' do
        let(:bad_path) { tmp_path.join('thisdoesnotexist') }

        it 'raises BerksfileNotFound' do
          expect {
            Berkshelf::Berksfile.from_file(bad_path)
          }.to raise_error(Berkshelf::BerksfileNotFound)
        end
      end
    end
  end

  let(:dependency_one) { double('dependency_one', name: 'nginx') }
  let(:dependency_two) { double('dependency_two', name: 'mysql') }

  subject do
    berksfile_path = tmp_path.join('Berksfile').to_s
    FileUtils.touch(berksfile_path)
    Berkshelf::Berksfile.new(berksfile_path)
  end

  describe '#cookbook' do
    let(:name) { 'artifact' }
    let(:constraint) { double('constraint') }
    let(:default_options) { { group: [] } }

    it 'sends the add_dependency message with the name, constraint, and options to the instance of the includer' do
      expect(subject).to receive(:add_dependency).with(name, constraint, default_options)
      subject.cookbook(name, constraint, default_options)
    end

    it 'merges the default options into specified options' do
      expect(subject).to receive(:add_dependency)do |arg_name, arg_constraint, arg_options|
        expect(arg_name).to eq(name)
        expect(arg_constraint).to eq(constraint)
        expect(arg_options[:path]).to match(%r{/Users/reset})
        expect(arg_options[:group]).to eq([])
      end

      subject.cookbook(name, constraint, path: '/Users/reset')
    end

    it 'converts a single specified group option into an array of groups' do
      expect(subject).to receive(:add_dependency).with(name, constraint, group: [:production])
      subject.cookbook(name, constraint, group: :production)
    end

    context 'when no constraint specified' do
      it 'sends the add_dependency message with a nil value for constraint' do
        expect(subject).to receive(:add_dependency).with(name, nil, default_options)
        subject.cookbook(name, default_options)
      end
    end

    context 'when no options specified' do
      it 'sends the add_dependency message with an empty Hash for the value of options' do
        expect(subject).to receive(:add_dependency).with(name, constraint, default_options)
        subject.cookbook(name, constraint)
      end
    end

    it "is a DSL method" do
      expect(subject).to have_exposed_method(:cookbook)
    end
  end

  describe '#group' do
    let(:name) { 'artifact' }
    let(:group) { 'production' }

    it 'sends the add_dependency message with an array of groups determined by the parameter to the group block' do
      expect(subject).to receive(:add_dependency).with(name, nil, group: [group])

      subject.group(group) do
        subject.cookbook(name)
      end
    end

    it "is a DSL method" do
      expect(subject).to have_exposed_method(:group)
    end
  end

  describe '#metadata' do
    let(:path) { fixtures_path.join('cookbooks/example_cookbook') }
    subject { Berkshelf::Berksfile.new(path.join('Berksfile')) }

    before { Dir.chdir(path) }

    it 'sends the add_dependency message with an explicit version constraint and the path to the cookbook' do
      expect(subject).to receive(:add_dependency).with('example_cookbook', nil, path: path.to_s, metadata: true)
      subject.metadata
    end

    it "is a DSL method" do
      expect(subject).to have_exposed_method(:metadata)
    end
  end

  describe "#source" do
    let(:new_source) { "http://berks.riotgames.com" }

    it "is a DSL method" do
      expect(subject).to have_exposed_method(:source)
    end

    it "adds a source to the sources" do
      subject.source(new_source)
      expect(subject.sources.map(&:to_s)).to include(new_source)
    end

    it "converts the string to a Source" do
      subject.source(new_source)
      subject.sources.each do |source|
        expect(source).to be_a(Berkshelf::Source)
      end
    end

    it "adds each source in order they appear" do
      subject.source(new_source)
      subject.source("http://berks.other.com")
      expect(subject.sources[0].to_s).to eq(new_source)
      expect(subject.sources[1].to_s).to eq("http://berks.other.com")
    end

    it "does not add duplicate entries" do
      subject.source(new_source)
      subject.source(new_source)
      expect(subject.sources[0].to_s).to eq(new_source)
      expect(subject.sources[1].to_s).to_not eq(new_source)
    end

    context "adding an invalid source" do
      let(:invalid_uri) { ".....$1233...." }

      it "raises an InvalidSourceURI" do
        expect { subject.source(invalid_uri) }.to raise_error(Berkshelf::InvalidSourceURI)
      end
    end
  end

  describe "#sources" do
    context "when there are no sources" do
      it "raises an exception" do
        expect {
          subject.sources
        }.to raise_error(Berkshelf::NoAPISourcesDefined)
      end
    end

    context "when there are sources" do
      before { subject.source("https://api.berkshelf.org") }

      it "returns an Array" do
        expect(subject.sources).to be_a(Array)
      end

      it "contains a collection of Berkshelf::Source" do
        subject.sources.each do |source|
          expect(source).to be_a(Berkshelf::Source)
        end
      end
    end
  end

  describe "#site" do
    it "raises a Berkshelf::Deprecated error" do
      expect { subject.site }.to raise_error(Berkshelf::DeprecatedError)
    end

    it "is a DSL method" do
      expect(subject).to have_exposed_method(:site)
    end
  end

  describe "#chef_api" do
    it "raises a Berkshelf::Deprecated error" do
      expect { subject.chef_api }.to raise_error(Berkshelf::DeprecatedError)
    end

    it "is a DSL method" do
      expect(subject).to have_exposed_method(:chef_api)
    end
  end

  describe '#extension' do
    it "is a DSL method" do
      expect(subject).to have_exposed_method(:extension)
    end
  end

  describe '#dependencies' do
    let(:groups) do
      [
        :nautilus,
        :skarner
      ]
    end

    it 'returns all Berkshelf::Dependencys added to the instance of Berksfile' do
      subject.add_dependency(dependency_one.name)
      subject.add_dependency(dependency_two.name)

      expect(subject.dependencies.size).to eq(2)
      expect(subject).to have_dependency(dependency_one.name)
      expect(subject).to have_dependency(dependency_two.name)
    end
  end

  describe '#cookbooks' do
    it 'raises an exception if a cookbook is not installed' do
      subject.add_dependency('bacon', nil)
      expect { subject.cookbooks }.to raise_error
    end

    it 'retrieves the locked (cached) cookbook for each dependency' do
      subject.add_dependency('bacon', nil)
      subject.add_dependency('ham', nil)
      allow(subject).to receive(:retrive_locked)

      expect(subject).to receive(:retrieve_locked).twice
      subject.cookbooks
    end
  end

  describe '#groups' do
    before do
      allow(subject).to receive(:dependencies) { [dependency_one, dependency_two] }
      allow(dependency_one).to receive(:groups) { [:nautilus, :skarner] }
      allow(dependency_two).to receive(:groups) { [:nautilus, :riven] }
    end

    it 'returns a hash containing keys for every group a dependency is a member of' do
      expect(subject.groups.keys.size).to eq(3)
      expect(subject.groups).to have_key(:nautilus)
      expect(subject.groups).to have_key(:skarner)
      expect(subject.groups).to have_key(:riven)
    end

    it 'returns an Array of Berkshelf::Dependencys who are members of the group for value' do
      expect(subject.groups[:nautilus].size).to eq(2)
      expect(subject.groups[:riven].size).to eq(1)
    end
  end

  describe '#add_dependency' do
    let(:name) { 'cookbook_one' }
    let(:constraint) { '= 1.2.0' }
    let(:options) { Hash.new }

    before(:each) do
      subject.add_dependency(name, constraint, options)
    end

    let(:dependency) { subject.dependencies.first }

    it 'adds new dependency to the list of dependencies' do
      expect(subject.dependencies.size).to eq(1)
    end

    it "is a Berkshelf::Dependency" do
      expect(dependency).to be_a(Berkshelf::Dependency)
    end

    it "has a name matching the given name" do
      expect(dependency.name).to eq(name)
    end

    it "has a version_constraint matching the given constraint" do
      expect(dependency.version_constraint.to_s).to eq(constraint)
    end

    it 'raises DuplicateDependencyDefined if multiple dependencies of the same name are found' do
      expect {
        subject.add_dependency(name)
      }.to raise_error(Berkshelf::DuplicateDependencyDefined)
    end

    it "has a nil location if no location options are provided" do
      expect(dependency.location).to be_nil
    end

    context "when given the :git option" do
      let(:options) { { git: "git@github.com:berkshelf/berkshelf.git" } }

      it "has a GitLocation location" do
        expect(dependency.location).to be_a(Berkshelf::GitLocation)
      end
    end

    context "when given the :github option" do
      let(:options) { { github: "berkshelf/berkshelf" } }

      it "has a GithubLocation location" do
        expect(dependency.location).to be_a(Berkshelf::GithubLocation)
      end
    end

    context "when given the :path option" do
      let(:options) { { path: fixtures_path.join('cookbooks', 'example_cookbook') } }

      it "has a PathLocation location" do
        expect(dependency.location).to be_a(Berkshelf::PathLocation)
      end
    end
  end

  describe '#retrieve_locked' do
    let(:lockfile) { double('lockfile') }
    let(:dependency) { double('dependency', name: 'bacon') }
    let(:locked) { double('locked', cached_cookbook: cached, locked_version: '1.0.0') }
    let(:cached) { double('cached') }

    before do
      allow(subject).to receive(:lockfile).and_return(lockfile)
    end

    it 'delegates to the lockfile' do
      expect(lockfile).to receive(:retrieve).with(dependency)
      subject.retrieve_locked(dependency)
    end
  end

  describe '#upload' do
    let(:uploader) { double(Berkshelf::Uploader, run: nil) }

    before do
      allow(subject).to receive(:validate_lockfile_present!)
      allow(subject).to receive(:validate_lockfile_trusted!)
      allow(subject).to receive(:validate_dependencies_installed!)

      allow(Berkshelf::Uploader).to receive(:new).and_return(uploader)
    end

    it 'validates the lockfile is present' do
      expect(subject).to receive(:validate_lockfile_present!).once
      subject.upload
    end

    it 'validates the lockfile is trusted' do
      expect(subject).to receive(:validate_lockfile_trusted!).once
      subject.upload
    end

    it 'validates the dependencies are installed' do
      expect(subject).to receive(:validate_dependencies_installed!).once
      subject.upload
    end

    it 'creates a new Uploader' do
      expect(Berkshelf::Uploader).to receive(:new).with(subject)
      expect(uploader).to receive(:run)

      subject.upload
    end
  end

  describe '#vendor' do
    let(:cached_cookbook)    { double(Berkshelf::CachedCookbook, cookbook_name: 'my_cookbook', path: '/my_cookbook/path', compiled_metadata?: true) }
    let(:installer)          { double(Berkshelf::Installer, run: [cached_cookbook]) }
    let(:raw_metadata_files) { [File::join(cached_cookbook.cookbook_name, 'metadata.rb')] }

    let(:destination) { '/a/destination/path' }
    let(:excludes)    { { :exclude => raw_metadata_files + Berkshelf::Berksfile::EXCLUDED_VCS_FILES_WHEN_VENDORING } }

    before do
      allow(Berkshelf::Installer).to receive(:new).and_return(installer)
    end

    it 'invokes FileSyncer with correct arguments' do
      expect(Berkshelf::FileSyncer).to receive(:sync).with(/vendor/, destination, excludes)

      subject.vendor(destination)
    end

    it 'excludes the top-level metadata.rb file' do
      expect(excludes[:exclude].any? { |exclude| File.fnmatch?(exclude, 'my_cookbook/recipes/metadata.rb', File::FNM_DOTMATCH) }).to be(false)
      expect(excludes[:exclude].any? { |exclude| File.fnmatch?(exclude, 'my_cookbook/metadata.rb', File::FNM_DOTMATCH) }).to be(true)
    end
  end
end
