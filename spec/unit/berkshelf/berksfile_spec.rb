require 'spec_helper'

describe Berkshelf::Berksfile do
  describe "ClassMethods" do
    describe "::default_sources" do
      subject { described_class.default_sources }

      it "returns an array including the default sources" do
        expect(subject).to be_a(Array)
        expect(subject).to have(1).item
        expect(subject.map(&:to_s)).to include("http://api.berkshelf.com")
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
      subject.should_receive(:add_dependency).with(name, constraint, path: '/Users/reset', group: [])
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

    context 'given the option :except' do
      before do
        dependency_one.stub(:groups) { [:default, :skarner] }
        dependency_two.stub(:groups) { [:default, :nautilus] }
      end

      it 'returns all of the dependencies except the ones in the given groups' do
        subject.add_dependency(dependency_one.name, nil, group: [:default, :skarner])
        subject.add_dependency(dependency_two.name, nil, group: [:default, :nautilus])
        filtered = subject.dependencies(except: :nautilus)

        expect(filtered).to have(1).item
        expect(filtered.first.name).to eq(dependency_one.name)
      end
    end

    context 'given the option :only' do
      before do
        dependency_one.stub(:groups) { [:default, :skarner] }
        dependency_two.stub(:groups) { [:default, :nautilus] }
      end

      it 'returns only the dependencies in the givne groups' do
        subject.add_dependency(dependency_one.name, nil, group: [:default, :skarner])
        subject.add_dependency(dependency_two.name, nil, group: [:default, :nautilus])
        filtered = subject.dependencies(only: :nautilus)

        expect(filtered).to have(1).item
        expect(filtered.first.name).to eq(dependency_two.name)
      end
    end

    context 'when a value for :only and :except is given' do
      it 'raises an ArgumentError' do
        expect {
          subject.dependencies(only: [:default], except: [:other])
        }.to raise_error(Berkshelf::ArgumentError, "Cannot specify both :except and :only")
      end
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

  describe "#install" do
    pending
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
      let(:options) { { git: "git@github.com:RiotGames/berkshelf.git" } }

      it "has a GitLocation location" do
        expect(dependency.location).to be_a(Berkshelf::GitLocation)
      end
    end

    context "when given the :github option" do
      let(:options) { { github: "RiotGames/berkshelf" } }

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
        Ridley.should_receive(:new).with(ridley_options)
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
        Ridley.should_receive(:new).with(ridley_options)
        upload
      end
    end
  end

  describe "#apply" do
    let(:env_name)    { 'berkshelf-test' }
    let(:server_url)  { Berkshelf::RSpec::ChefServer.server_url }
    let(:client_name) { 'reset' }
    let(:client_key)  { fixtures_path.join('reset.pem').to_s }
    let(:ridley)      { Ridley.new(server_url: server_url, client_name: client_name, client_key: client_key) }

    before do
      subject.stub(:ridley_connection).and_return(ridley)
      subject.add_dependency('nginx', '>= 0.1.2')
      subject.stub(install: nil)
    end

    context 'when the chef environment exists' do
      let(:dependencies) do
        [
          double(name: 'nginx', locked_version: '1.2.3'),
          double(name: 'artifact', locked_version: '1.4.0')
        ]
      end

      before do
        chef_environment('berkshelf')
        subject.lockfile.stub(:dependencies).and_return(dependencies)
      end

      it 'installs the Berksfile' do
        subject.should_receive(:install)
        subject.apply('berkshelf')
      end

      it 'applys the locked_versions of the Lockfile dependencies to the given Chef environment' do
        subject.apply('berkshelf')

        environment = ::JSON.parse(chef_server.data_store.get(['environments', 'berkshelf']))
        expect(environment['cookbook_versions']).to have(2).items
        expect(environment['cookbook_versions']['nginx']).to eq('1.2.3')
        expect(environment['cookbook_versions']['artifact']).to eq('1.4.0')
      end
    end

    context 'when the environment does not exist' do
      it 'raises an EnvironmentNotFound error' do
        expect {
          subject.apply(env_name)
        }.to raise_error(Berkshelf::EnvironmentNotFound)
      end
    end

    context 'when Ridley throw an exception' do
      before { ridley.stub_chain(:environment, :find).and_raise(Ridley::Errors::RidleyError) }

      it 'raises a ChefConnectionError' do
        expect {
          subject.apply(env_name)
        }.to raise_error(Berkshelf::ChefConnectionError)
      end
    end
  end

  describe '#package' do
    context 'when the dependency does not exist' do
      it 'raises a CookbookNotFound exception' do
        expect {
          subject.package('non-existent', output: '/tmp')
        }.to raise_error(Berkshelf::CookbookNotFound)
      end
    end

    context 'when the dependency exists' do
      let(:dependency) { double('dependency') }
      let(:cached) { double('cached', path: '/foo/bar', cookbook_name: 'cookbook') }
      let(:options) { { output: '/tmp' } }

      before do
        FileUtils.stub(:cp_r)
        FileUtils.stub(:mkdir_p)
        subject.stub(:find).with('non-existent').and_return(dependency)
        subject.stub(:resolve).with(dependency, options).and_return({ solution: [cached], dependencies: [dependency] })
      end

      it 'resolves the dependencies' do
        subject.should_receive(:resolve).with(dependency, options)
        subject.package('non-existent', options)
      end

      it 'returns the output path' do
        expect(subject.package('non-existent', options)).to eq('/tmp/non-existent.tar.gz')
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
      }.to raise_error(Berkshelf::InvalidCookbookFiles)
    end

    it 'does not raise an error when the cookbook is valid' do
      Dir.stub(:glob).and_return(['/there-are/no-spaces/in-this/recipes/default.rb'])
      expect {
        subject.validate_files!(cookbook)
      }.to_not raise_error(Berkshelf::InvalidCookbookFiles)
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
