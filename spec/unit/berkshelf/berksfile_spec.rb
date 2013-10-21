require 'spec_helper'

describe Berkshelf::Berksfile do
  describe '.from_file' do
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
        expect(subject).to have_source(name)
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

  describe '.vendor' do
    let(:cached_cookbooks) { [] }
    let(:tmpdir) { Dir.mktmpdir(nil, tmp_path) }

    it 'returns the expanded filepath of the vendor directory' do
      expect(Berkshelf::Berksfile.vendor(cached_cookbooks, tmpdir)).to eql(tmpdir)
    end

    context 'with a chefignore' do
      before do
        File.stub(:exists?).and_return(true)
        Berkshelf::Chef::Cookbook::Chefignore.any_instance.stub(:remove_ignores_from).and_return(['metadata.rb'])
      end

      it 'finds a chefignore file' do
        Berkshelf::Chef::Cookbook::Chefignore.should_receive(:new).with(File.expand_path('chefignore'))
        Berkshelf::Berksfile.vendor(cached_cookbooks, tmpdir)
      end

      it 'removes files in chefignore' do
        cached_cookbooks = [ Berkshelf::CachedCookbook.from_path(fixtures_path.join('cookbooks/example_cookbook')) ]
        FileUtils.should_receive(:cp_r).with(['metadata.rb'], anything()).exactly(1).times
        FileUtils.should_receive(:cp_r).with(anything(), anything(), anything()).once
        Berkshelf::Berksfile.vendor(cached_cookbooks, tmpdir)
      end
    end
  end



  let(:source_one) { double('source_one', name: 'nginx') }
  let(:source_two) { double('source_two', name: 'mysql') }

  subject do
    berksfile_path = tmp_path.join('Berksfile').to_s
    FileUtils.touch(berksfile_path)
    Berkshelf::Berksfile.new(berksfile_path)
  end

  describe '#cookbook' do
    let(:name) { 'artifact' }
    let(:constraint) { double('constraint') }
    let(:default_options) { { group: [] } }

    it 'sends the add_source message with the name, constraint, and options to the instance of the includer' do
      subject.should_receive(:add_source).with(name, constraint, default_options)
      subject.cookbook(name, constraint, default_options)
    end

    it 'merges the default options into specified options' do
      subject.should_receive(:add_source).with(name, constraint, path: '/Users/reset', group: [])
      subject.cookbook(name, constraint, path: '/Users/reset')
    end

    it 'converts a single specified group option into an array of groups' do
      subject.should_receive(:add_source).with(name, constraint, group: [:production])
      subject.cookbook(name, constraint, group: :production)
    end

    context 'when no constraint specified' do
      it 'sends the add_source message with a nil value for constraint' do
        subject.should_receive(:add_source).with(name, nil, default_options)
        subject.cookbook(name, default_options)
      end
    end

    context 'when no options specified' do
      it 'sends the add_source message with an empty Hash for the value of options' do
        subject.should_receive(:add_source).with(name, constraint, default_options)
        subject.cookbook(name, constraint)
      end
    end
  end

  describe '#group' do
    let(:name) { 'artifact' }
    let(:group) { 'production' }

    it 'sends the add_source message with an array of groups determined by the parameter passed to the group block' do
      subject.should_receive(:add_source).with(name, nil, group: [group])

      subject.group(group) do
        subject.cookbook(name)
      end
    end
  end

  describe '#metadata' do
    let(:path) { fixtures_path.join('cookbooks/example_cookbook') }
    subject { Berkshelf::Berksfile.new(path.join('Berksfile')) }

    before { Dir.chdir(path) }

    it 'sends the add_source message with no version constraint, the path to the cookbook, and the metadata definition' do
      subject.should_receive(:add_source).with('example_cookbook', nil, path: path.to_s, metadata: true)
      subject.metadata
    end
  end

  describe '#site' do
    let(:uri) { 'http://opscode/v1' }

    it 'sends the add_location to the instance of the implementing class with a SiteLocation' do
      subject.should_receive(:add_location).with(:site, uri)
      subject.site(uri)
    end

    context 'given the symbol :opscode' do
      it 'sends an add_location message with the default Opscode Community API as the first parameter' do
        subject.should_receive(:add_location).with(:site, :opscode)
        subject.site(:opscode)
      end
    end
  end

  describe '#chef_api' do
    let(:uri) { 'http://chef:8080/' }

    it 'sends and add_location message with the type :chef_api and the given URI' do
      subject.should_receive(:add_location).with(:chef_api, uri, {})
      subject.chef_api(uri)
    end

    it 'also sends any options passed' do
      options = { node_name: 'reset', client_key: '/Users/reset/.chef/reset.pem' }
      subject.should_receive(:add_location).with(:chef_api, uri, options)
      subject.chef_api(uri, options)
    end

    context 'given the symbol :config' do
      it 'sends an add_location message with the the type :chef_api and the URI :config' do
        subject.should_receive(:add_location).with(:chef_api, :config, {})
        subject.chef_api(:config)
      end
    end
  end

  describe '#sources' do
    let(:groups) do
      [
        :nautilus,
        :skarner
      ]
    end

    it 'returns all CookbookSources added to the instance of Berksfile' do
      subject.add_source(source_one.name)
      subject.add_source(source_two.name)

      expect(subject.sources).to have(2).items
      expect(subject).to have_source(source_one.name)
      expect(subject).to have_source(source_two.name)
    end

    context 'given the option :except' do
      before do
        source_one.stub(:groups) { [:default, :skarner] }
        source_two.stub(:groups) { [:default, :nautilus] }
      end

      it 'returns all of the sources except the ones in the given groups' do
        subject.add_source(source_one.name, nil, group: [:default, :skarner])
        subject.add_source(source_two.name, nil, group: [:default, :nautilus])
        filtered = subject.sources(except: :nautilus)

        expect(filtered).to have(1).item
        expect(filtered.first.name).to eq(source_one.name)
      end
    end

    context 'given the option :only' do
      before do
        source_one.stub(:groups) { [:default, :skarner] }
        source_two.stub(:groups) { [:default, :nautilus] }
      end

      it 'returns only the sources in the givne groups' do
        subject.add_source(source_one.name, nil, group: [:default, :skarner])
        subject.add_source(source_two.name, nil, group: [:default, :nautilus])
        filtered = subject.sources(only: :nautilus)

        expect(filtered).to have(1).item
        expect(filtered.first.name).to eq(source_two.name)
      end
    end

    context 'when a value for :only and :except is given' do
      it 'raises an ArgumentError' do
        expect {
          subject.sources(only: [:default], except: [:other])
        }.to raise_error(Berkshelf::ArgumentError, "Cannot specify both :except and :only")
      end
    end
  end

  describe '#groups' do
    before do
      subject.stub(:sources) { [source_one, source_two] }
      source_one.stub(:groups) { [:nautilus, :skarner] }
      source_two.stub(:groups) { [:nautilus, :riven] }
    end

    it 'returns a hash containing keys for every group a source is a member of' do
      expect(subject.groups.keys).to have(3).items
      expect(subject.groups).to have_key(:nautilus)
      expect(subject.groups).to have_key(:skarner)
      expect(subject.groups).to have_key(:riven)
    end

    it 'returns an Array of CookbookSources who are members of the group for value' do
      expect(subject.groups[:nautilus]).to have(2).items
      expect(subject.groups[:riven]).to have(1).item
    end
  end

  describe '#resolve' do
    let(:resolver) { double('resolver') }
    let(:sources) { [source_one, source_two] }
    let(:cached) { [double('cached_one'), double('cached_two')] }

    before do
      Berkshelf::Resolver.stub(:new).and_return(resolver)
    end

    it 'resolves the Berksfile' do
      resolver.should_receive(:resolve).and_return(cached)
      resolver.should_receive(:sources).and_return(sources)

      expect(subject.resolve).to eq({ solution: cached, sources: sources })
    end
  end

  describe '#install' do
    let(:resolver) { double('resolver') }
    let(:lockfile) { double('lockfile') }

    let(:cached_cookbooks) { [double('cached_one'), double('cached_two')] }
    let(:sources) { [source_one, source_two] }

    before do
      Berkshelf::Resolver.stub(:new).and_return(resolver)
      Berkshelf::Lockfile.stub(:new).and_return(lockfile)

      lockfile.stub(:sources).and_return([])

      resolver.stub(:sources).and_return([])
      lockfile.stub(:update)
    end

    context 'when a lockfile is not present' do
      it 'returns the result from sending the message resolve to resolver' do
        resolver.should_receive(:resolve).and_return(cached_cookbooks)
        expect(subject.install).to eql(cached_cookbooks)
      end

      it 'sets a value for self.cached_cookbooks equivalent to the return value' do
        resolver.should_receive(:resolve).and_return(cached_cookbooks)
        subject.install

        expect(subject.cached_cookbooks).to eql(cached_cookbooks)
      end

      it 'creates a new resolver and finds a solution by calling resolve on the resolver' do
        resolver.should_receive(:resolve)
        subject.install
      end

      it 'writes a lockfile with the resolvers sources' do
        resolver.should_receive(:resolve)
        lockfile.should_receive(:update).with([])

        subject.install
      end
    end

    context 'when a value for :path is given' do
      before do
        resolver.should_receive(:resolve)
        resolver.should_receive(:sources).and_return([])
      end

      it 'sends the message :vendor to Berksfile with the value for :path' do
        path = double('path')
        subject.class.should_receive(:vendor).with(subject.cached_cookbooks, path)

        subject.install(path: path)
      end
    end

    context 'when a value for :except is given' do
      before do
        resolver.should_receive(:resolve)
        resolver.should_receive(:sources).and_return([])
        subject.stub(:sources).and_return(sources)
        subject.stub(:apply_lockfile).and_return(sources)
      end

      it 'filters the sources and gives the results to the Resolver initializer' do
        subject.should_receive(:sources).with(except: [:skip_me]).and_return(sources)
        subject.install(except: [:skip_me])
      end
    end

    context 'when a value for :only is given' do
      before do
        resolver.should_receive(:resolve)
        resolver.should_receive(:sources).and_return([])
        subject.stub(:sources).and_return(sources)
        subject.stub(:apply_lockfile).and_return(sources)
      end

      it 'filters the sources and gives the results to the Resolver initializer' do
        subject.should_receive(:sources).with(only: [:skip_me]).and_return(sources)
        subject.install(only: [:skip_me])
      end
    end
  end

  describe '#add_source' do
    let(:name) { 'cookbook_one' }
    let(:constraint) { '= 1.2.0' }
    let(:location) { { site: 'http://site' } }

    before(:each) do
      subject.add_source(name, constraint, location)
    end

    it 'adds new cookbook source to the list of sources' do
      expect(subject.sources).to have(1).source
    end

    it "adds a cookbook source with a 'name' of the given name" do
      expect(subject.sources.first.name).to eq(name)
    end

    it "adds a cookbook source with a 'version_constraint' of the given constraint" do
      expect(subject.sources.first.version_constraint.to_s).to eq(constraint)
    end

    it 'raises DuplicateSourceDefined if multiple sources of the same name are found' do
      expect {
        subject.add_source(name)
      }.to raise_error(Berkshelf::DuplicateSourceDefined)
    end
  end

  describe '#add_location' do
    let(:type) { :site }
    let(:value) { double('value') }
    let(:options) { double('options') }

    it 'delegates :add_location to the downloader' do
      subject.downloader.should_receive(:add_location).with(type, value, options)
      subject.add_location(type, value, options)
    end
  end

  describe '#upload' do
    let(:options) { Hash.new }
    let(:chef_config) do
      double('chef-config',
        node_name: 'fake-client',
        client_key: 'client-key',
        chef_server_url: 'http://configured-chef-server/'
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
      Berkshelf::Config.stub(:instance).and_return(berkshelf_config)
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
        Ridley.should_receive(:new).with(ridley_options)
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
        Ridley.should_receive(:new).with(ridley_options)
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
      let(:server_url)  { Berkshelf::RSpec::ChefServer.server_url }
      let(:client_name) { 'reset' }
      let(:client_key) { 'client-key' }
      let(:ridley_connection)      { double('ridley-connection', server_url: server_url, client_name: client_name, client_key: client_key) }
      let(:cookbook_resource) { double('cookbook') }

      it 'uses the passed in :validate' do
        Ridley.stub(:new).with(ridley_options).and_return(ridley_connection)
        ridley_connection.stub(:alive?).and_return(true)
        ridley_connection.stub(:terminate).and_return(true)
        ridley_connection.should_receive(:cookbook).and_return(cookbook_resource)
        cookbook_resource.should_receive(:upload).with('path', options )
        upload
      end
    end
  end

  describe '#apply' do
    let(:env_name)    { 'berkshelf-test' }
    let(:server_url)  { Berkshelf::RSpec::ChefServer.server_url }
    let(:client_name) { 'reset' }
    let(:client_key)  { fixtures_path.join('reset.pem').to_s }
    let(:ridley)      { Ridley.new(server_url: server_url, client_name: client_name, client_key: client_key) }

    before do
      subject.stub(:ridley_connection).and_return(ridley)
      subject.add_source('nginx', '>= 0.1.2', chef_api: server_url, node_name: client_name, client_key: client_key)
      subject.stub(install: nil)
    end

    context 'when the chef environment exists' do
      let(:sources) do
        [
          double(name: 'nginx', locked_version: '1.2.3'),
          double(name: 'artifact', locked_version: '1.4.0')
        ]
      end

      before do
        chef_environment('berkshelf')
        subject.lockfile.stub(:sources).and_return(sources)
      end

      it 'installs the Berksfile' do
        subject.should_receive(:install)
        subject.apply('berkshelf')
      end

      it 'applys the locked_versions of the Lockfile sources to the given Chef environment' do
        subject.apply('berkshelf')

        environment = ::JSON.parse(chef_server.data_store.get(['environments', 'berkshelf']))
        expect(environment['cookbook_versions']).to have(2).items
        expect(environment['cookbook_versions']['nginx']).to eq('= 1.2.3')
        expect(environment['cookbook_versions']['artifact']).to eq('= 1.4.0')
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
    context 'when the source does not exist' do
      it 'raises a CookbookNotFound exception' do
        expect {
          subject.package('non-existent', output: '/tmp')
        }.to raise_error(Berkshelf::CookbookNotFound)
      end
    end

    context 'when the source exists' do
      let(:source) { double('source') }
      let(:cached) { double('cached', path: '/foo/bar', cookbook_name: 'cookbook') }
      let(:options) { { output: '/tmp' } }

      before do
        FileUtils.stub(:cp_r)
        FileUtils.stub(:mkdir_p)
        subject.stub(:find).with('non-existent').and_return(source)
        subject.stub(:resolve).with(source, options).and_return({ solution: [cached], sources: [source] })
      end

      it 'resolves the sources' do
        subject.should_receive(:resolve).with(source, options)
        subject.package('non-existent', options)
      end

      it 'returns the output path' do
        expect(subject.package('non-existent', options)).to eq('/tmp/non-existent.tar.gz')
      end
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
