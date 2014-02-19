require 'spec_helper'

describe Berkshelf::Berksfile do
  describe "ClassMethods" do
    describe "::default_sources" do
      subject { described_class.default_sources }

      it "returns an array including the default sources" do
        expect(subject).to be_a(Array)
        expect(subject).to have(1).item
        expect(subject.map(&:to_s)).to include("https://api.berkshelf.com")
      end
    end

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
      subject.should_receive(:add_dependency).with(name, constraint, default_options)
      subject.cookbook(name, constraint, default_options)
    end

    it 'merges the default options into specified options' do
      subject.should_receive(:add_dependency)do |arg_name, arg_constraint, arg_options|
        expect(arg_name).to eq(name)
        expect(arg_constraint).to eq(constraint)
        expect(arg_options[:path]).to match(%r{/Users/reset})
        expect(arg_options[:group]).to eq([])
      end

      subject.cookbook(name, constraint, path: '/Users/reset')
    end

    it 'converts a single specified group option into an array of groups' do
      subject.should_receive(:add_dependency).with(name, constraint, group: [:production])
      subject.cookbook(name, constraint, group: :production)
    end

    context 'when no constraint specified' do
      it 'sends the add_dependency message with a nil value for constraint' do
        subject.should_receive(:add_dependency).with(name, nil, default_options)
        subject.cookbook(name, default_options)
      end
    end

    context 'when no options specified' do
      it 'sends the add_dependency message with an empty Hash for the value of options' do
        subject.should_receive(:add_dependency).with(name, constraint, default_options)
        subject.cookbook(name, constraint)
      end
    end
  end

  describe '#group' do
    let(:name) { 'artifact' }
    let(:group) { 'production' }

    it 'sends the add_dependency message with an array of groups determined by the parameter to the group block' do
      subject.should_receive(:add_dependency).with(name, nil, group: [group])

      subject.group(group) do
        subject.cookbook(name)
      end
    end
  end

  describe '#metadata' do
    let(:path) { fixtures_path.join('cookbooks/example_cookbook') }
    subject { Berkshelf::Berksfile.new(path.join('Berksfile')) }

    before { Dir.chdir(path) }

    it 'sends the add_dependency message with an explicit version constraint and the path to the cookbook' do
      subject.should_receive(:add_dependency).with('example_cookbook', nil, path: path.to_s, metadata: true)
      subject.metadata
    end
  end

  describe "#source" do
    let(:new_source) { "http://berks.riotgames.com" }

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

    context "when a source is explicitly specified" do
      it "does not include the default sources in the list" do
        subject.source(new_source)
        expect(subject.sources).to have(1).item
        expect(subject.sources).to_not include(described_class.default_sources)
      end
    end

    context "adding an invalid source" do
      let(:invalid_uri) { ".....$1233...." }

      it "raises an InvalidSourceURI" do
        expect { subject.source(invalid_uri) }.to raise_error(Berkshelf::InvalidSourceURI)
      end
    end
  end

  describe "#sources" do
    it "returns an Array" do
      expect(subject.sources).to be_a(Array)
    end

    it "contains a collection of Berkshelf::Source" do
      subject.sources.each do |source|
        expect(source).to be_a(Berkshelf::Source)
      end
    end

    it "includes the default sources" do
      expect(subject.sources).to include(*described_class.default_sources)
    end
  end

  describe "#site" do
    it "raises a Berkshelf::Deprecated error" do
      expect { subject.site }.to raise_error(Berkshelf::DeprecatedError)
    end
  end

  describe "#chef_api" do
    it "raises a Berkshelf::Deprecated error" do
      expect { subject.chef_api }.to raise_error(Berkshelf::DeprecatedError)
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

      expect(subject.dependencies).to have(2).items
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
      subject.stub(:retrive_locked)

      expect(subject).to receive(:retrieve_locked).twice
      subject.cookbooks
    end
  end

  describe '#groups' do
    before do
      subject.stub(:dependencies) { [dependency_one, dependency_two] }
      dependency_one.stub(:groups) { [:nautilus, :skarner] }
      dependency_two.stub(:groups) { [:nautilus, :riven] }
    end

    it 'returns a hash containing keys for every group a dependency is a member of' do
      expect(subject.groups.keys).to have(3).items
      expect(subject.groups).to have_key(:nautilus)
      expect(subject.groups).to have_key(:skarner)
      expect(subject.groups).to have_key(:riven)
    end

    it 'returns an Array of Berkshelf::Dependencys who are members of the group for value' do
      expect(subject.groups[:nautilus]).to have(2).items
      expect(subject.groups[:riven]).to have(1).item
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
      expect(subject.dependencies).to have(1).dependency
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
      subject.stub(:lockfile).and_return(lockfile)
    end

    it 'delegates to the lockfile' do
      expect(lockfile).to receive(:retrieve).with(dependency)
      subject.retrieve_locked(dependency)
    end
  end

  describe '#upload' do
    let(:options) { Hash.new }
    let(:chef_config) do
      double('chef-config',
        node_name: 'fake-client',
        client_key: 'client-key',
        chef_server_url: 'http://configured-chef-server/',
        validation_client_name: 'validator',
        validation_key: 'validator.pem',
        cookbook_copyright: 'user',
        cookbook_email: 'user@example.com',
        cookbook_license: 'apachev2',
      )
    end
    let(:berkshelf_config) { double('berkshelf-config', ssl: double(verify: true), chef: chef_config) }
    let(:default_ridley_options) do
      {
        client_name: 'fake-client',
        client_key: 'client-key',
        ssl: {
          verify: true
        }
      }
    end
    let(:installed_cookbooks) { Array.new }

    let(:upload) { subject.upload(options) }

    before do
      Berkshelf.stub(:config).and_return(berkshelf_config)
      subject.should_receive(:install).and_return(installed_cookbooks)
    end

    context 'when there is no value for :chef_server_url' do
      before { chef_config.stub(chef_server_url: nil) }
      let(:message) { 'Missing required attribute in your Berkshelf configuration: chef.server_url' }

      it 'raises an error' do
        expect { upload }.to raise_error(Berkshelf::ChefConnectionError, message)
      end
    end

    context 'when there is no value for :client_name' do
      before { chef_config.stub(node_name: nil) }
      let(:message) { 'Missing required attribute in your Berkshelf configuration: chef.node_name' }

      it 'raises an error' do
        expect { upload }.to raise_error(Berkshelf::ChefConnectionError, message)
      end
    end

    context 'when there is no value for :client_key' do
      before { chef_config.stub(client_key: nil) }
      let(:message) { 'Missing required attribute in your Berkshelf configuration: chef.client_key' }

      it 'raises an error' do
        expect {
          upload
        }.to raise_error(Berkshelf::ChefConnectionError, message)
      end
    end

    context 'when a Chef Server url is not passed as an option' do
      let(:ridley_options) do
        { server_url: 'http://configured-chef-server/' }.merge(default_ridley_options)
      end

      it 'uses Berkshelf::Config configured server_url' do
        Ridley.should_receive(:open).with(ridley_options)
        upload
      end
    end

    context 'when a Chef Server url is passed as an option' do
      let(:options) do
        {
          server_url: 'http://fake-chef-server.com/'
        }
      end
      let(:ridley_options) do
        { server_url: 'http://fake-chef-server.com/'}.merge(default_ridley_options)
      end

      it 'uses the passed in :server_url' do
        Ridley.should_receive(:open).with(ridley_options)
        upload
      end
    end

    context 'when a client name is passed as an option' do
      let(:options) do
        {
            client_name: 'passed-in-client-name'
        }
      end
      let(:ridley_options) do
        default_ridley_options.merge(
            { server_url: 'http://configured-chef-server/', client_name: 'passed-in-client-name'})
      end

      it 'uses the passed in :client_name' do
        Ridley.should_receive(:open).with(ridley_options)
        upload
      end
    end

    context 'when a client key is passed as an option' do
      let(:options) do
        {
            client_key: 'passed-in-client-key'
        }
      end
      let(:ridley_options) do
        default_ridley_options.merge(
            { server_url: 'http://configured-chef-server/', client_key: 'passed-in-client-key'})
      end

      it 'uses the passed in :client_key' do
        Ridley.should_receive(:open).with(ridley_options)
        upload
      end
    end

    context 'when validate is passed' do
      let(:options) do
        {
          force: false,
          freeze: true,
          validate: false,
          name: "cookbook"
        }
      end
      let(:ridley_options) do
        default_ridley_options.merge(
            { server_url: 'http://configured-chef-server/'})
      end
      let(:cookbook) { double('cookbook', cookbook_name: 'cookbook', path: 'path', version: '1.0.0') }
      let(:installed_cookbooks) { [ cookbook ] }
      let(:cookbook_resource) { double('cookbook') }
      let(:conn) { double('conn') }

      it 'uses the passed in :validate' do
        Ridley.should_receive(:open).with(ridley_options).and_yield(conn)
        conn.should_receive(:cookbook).and_return(cookbook_resource)
        cookbook_resource.should_receive(:upload).with('path', options )
        upload
      end
    end
  end

  describe "#remove_dependency" do
    let(:dependency) { "nginx" }
    before { subject.add_dependency(dependency) }

    it "removes a dependencies from the list" do
      subject.remove_dependency(dependency)
      expect(subject.dependencies).to have(0).items
    end
  end

  describe '#validate_files!' do
    before { described_class.send(:public, :validate_files!) }
    let(:cookbook) { double('cookbook', cookbook_name: 'cookbook', path: 'path') }

    it 'raises an error when the cookbook has spaces in the files' do
      Dir.stub(:glob).and_return(['/there are/spaces/in this/recipes/default.rb'])
      expect {
        subject.validate_files!(cookbook)
      }.to raise_error
    end

    it 'does not raise an error when the cookbook is valid' do
      Dir.stub(:glob).and_return(['/there-are/no-spaces/in-this/recipes/default.rb'])
      expect {
        subject.validate_files!(cookbook)
      }.to_not raise_error
    end

    it 'does not raise an exception with spaces in the path' do
      Dir.stub(:glob).and_return(['/there are/spaces/in this/recipes/default.rb'])
      Pathname.any_instance.stub(:dirname).and_return('/there are/spaces/in this')

      expect {
        subject.validate_files!(cookbook)
      }.to_not raise_error
    end
  end
end
