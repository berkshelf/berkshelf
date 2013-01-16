require 'spec_helper'

module Berkshelf
  describe Berksfile do
    let(:content) do
      """
      cookbook 'ntp', '<= 1.0.0'
      cookbook 'mysql'
      cookbook 'nginx', '< 0.101.2'
      cookbook 'ssh_known_hosts2', :git => 'https://github.com/erikh/chef-ssh_known_hosts2.git'
      """
    end

    let(:filepath) { tmp_path.join("Berksfile").to_s }
    let(:source_one) { double('source_one', name: "nginx") }
    let(:source_two) { double('source_two', name: "mysql") }

    subject { Berksfile.new(filepath) }

    #
    # Class Methods
    #
    describe ',from_file' do
      let(:cookbook_file) { fixtures_path.join('lockfile_spec', 'with_lock', 'Berksfile') }

      it "reads a Berksfile and returns an instance Berksfile" do
        Berksfile.from_file(cookbook_file).should be_a(Berksfile)
      end

      context "when Berksfile does not exist at given path" do
        let(:bad_path) { tmp_path.join("thisdoesnotexist") }

        it "raises BerksfileNotFound" do
          lambda {
            Berksfile.from_file(bad_path)
          }.should raise_error(BerksfileNotFound)
        end
      end
    end

    describe '.vendor' do
      context 'is deprecated' do
        before { ::Berkshelf::Installer.stub(:install) }
        after { Berksfile.vendor([source_one, source_two], '/tmp/nowhere') }

        it 'prints a deprecation warning' do
          ::Berkshelf.ui.should_receive(:deprecated)
        end

        it 'calls Berkshelf::Installer.install' do
          ::Berkshelf::Installer.should_receive(:install).once
        end
      end
    end

    #
    # Instance Methods
    #
    describe '#sha' do
      before do
        ::File.stub(:read).with(filepath).and_return('abc123')
        ::File.should_receive(:read)

        ::Digest::SHA1.stub(:hexdigest).with('abc123').and_return('aaabbbccc111222333')
        ::Digest::SHA1.should_receive(:hexdigest).with('abc123')
      end

      it 'sets the @sha instance variable' do
        subject.sha
        expect(subject.instance_variable_get(:@sha)).to eq('aaabbbccc111222333')
      end
    end

    describe "#cookbook" do
      let(:name) { "artifact" }
      let(:constraint) { double('constraint') }
      let(:default_options) { { group: [] } }

      it "sends the add_source message with the name, constraint, and options to the instance of the includer" do
        subject.should_receive(:add_source).with(name, constraint, default_options)

        subject.cookbook name, constraint, default_options
      end

      it "merges the default options into specified options" do
        subject.should_receive(:add_source).with(name, constraint, path: "/Users/reset", group: [])

        subject.cookbook name, constraint, path: "/Users/reset"
      end

      it "converts a single specified group option into an array of groups" do
        subject.should_receive(:add_source).with(name, constraint, group: [:production])

        subject.cookbook name, constraint, group: :production
      end

      context "when no constraint specified" do
        it "sends the add_source message with a nil value for constraint" do
          subject.should_receive(:add_source).with(name, nil, default_options)

          subject.cookbook name, default_options
        end
      end

      context "when no options specified" do
        it "sends the add_source message with an empty Hash for the value of options" do
          subject.should_receive(:add_source).with(name, constraint, default_options)

          subject.cookbook name, constraint
        end
      end
    end

    describe '#group' do
      let(:name) { "artifact" }
      let(:group) { "production" }

      it "sends the add_source message with an array of groups determined by the parameter passed to the group block" do
        subject.should_receive(:add_source).with(name, nil, group: [group])

        subject.group group do
          subject.cookbook name
        end
      end
    end

    describe "#metadata" do
      let(:cb_path) { fixtures_path.join('cookbooks/example_cookbook') }
      subject { Berksfile.new(cb_path.join("Berksfile")) }

      before(:each) { Dir.chdir(cb_path) }

      it "sends the add_source message with an explicit version constraint and the path to the cookbook" do
        subject.should_receive(:add_source).with("example_cookbook", "= 0.5.0", path: cb_path.to_s)

        subject.metadata
      end

      it 'raises an except when the metadata file was not found' do
        Berkshelf.stub(:find_metadata).and_return(nil)
        expect {
          subject.metadata
        }.to raise_error(Berkshelf::CookbookNotFound)
      end

      it 'uses the metadata name' do
        metadata = double('metadata')
        ::Chef::Cookbook::Metadata.stub(:new).and_return(metadata)
        metadata.stub(:from_file).with(any_args())
        metadata.stub(:name).with(any_args).and_return('example_cookbook')
        metadata.stub(:version).and_return('1.1.1')

        metadata.should_receive(:name)
        subject.metadata
      end
    end

    describe "#site" do
      let(:uri) { "http://opscode/v1" }

      it "sends the add_location to the instance of the implementing class with a SiteLocation" do
        subject.should_receive(:add_location).with(:site, uri)

        subject.site(uri)
      end

      context "given the symbol :opscode" do
        it "sends an add_location message with the default Opscode Community API as the first parameter" do
          subject.should_receive(:add_location).with(:site, :opscode)

          subject.site(:opscode)
        end
      end
    end

    describe "#chef_api" do
      let(:uri) { "http://chef:8080/" }

      it "sends and add_location message with the type :chef_api and the given URI" do
        subject.should_receive(:add_location).with(:chef_api, uri, {})

        subject.chef_api(uri)
      end

      it "also sends any options passed" do
        options = { node_name: "reset", client_key: "/Users/reset/.chef/reset.pem" }
        subject.should_receive(:add_location).with(:chef_api, uri, options)

        subject.chef_api(uri, options)
      end

      context "given the symbol :config" do
        it "sends an add_location message with the the type :chef_api and the URI :config" do
          subject.should_receive(:add_location).with(:chef_api, :config, {})

          subject.chef_api(:config)
        end
      end
    end

    describe "#sources" do
      let(:groups) do
        [
          :nautilus,
          :skarner
        ]
      end

      it "returns all CookbookSources added to the instance of Berksfile" do
        subject.add_source(source_one.name)
        subject.add_source(source_two.name)

        subject.sources.should have(2).items
        subject.should have_source(source_one.name)
        subject.should have_source(source_two.name)
      end

      context "given the option :except" do
        before(:each) do
          source_one.stub(:groups) { [:default, :skarner] }
          source_two.stub(:groups) { [:default, :nautilus] }
        end

        it "returns all of the sources except the ones in the given groups" do
          subject.add_source(source_one.name, nil, group: [:default, :skarner])
          subject.add_source(source_two.name, nil, group: [:default, :nautilus])
          filtered = subject.sources(except: :nautilus)

          filtered.should have(1).item
          filtered.first.name.should eql(source_one.name)
        end
      end

      context "given the option :only" do
        before(:each) do
          source_one.stub(:groups) { [:default, :skarner] }
          source_two.stub(:groups) { [:default, :nautilus] }
        end

        it "returns only the sources in the givne groups" do
          subject.add_source(source_one.name, nil, group: [:default, :skarner])
          subject.add_source(source_two.name, nil, group: [:default, :nautilus])
          filtered = subject.sources(only: :nautilus)

          filtered.should have(1).item
          filtered.first.name.should eql(source_two.name)
        end
      end

      context "when a value for :only and :except is given" do
        it "raises an ArgumentError" do
          lambda {
            subject.sources(only: [:default], except: [:other])
          }.should raise_error(Berkshelf::ArgumentError, "Cannot specify both :except and :only")
        end
      end
    end

    describe "#groups" do
      before(:each) do
        subject.stub(:sources) { [source_one, source_two] }
        source_one.stub(:groups) { [:nautilus, :skarner] }
        source_two.stub(:groups) { [:nautilus, :riven] }
      end

      it "returns a hash containing keys for every group a source is a member of" do
        subject.groups.keys.should have(3).items
        subject.groups.should have_key(:nautilus)
        subject.groups.should have_key(:skarner)
        subject.groups.should have_key(:riven)
      end

      it "returns an Array of CookbookSources who are members of the group for value" do
        subject.groups[:nautilus].should have(2).items
        subject.groups[:riven].should have(1).item
      end
    end

    describe "#resolve" do
      let(:resolver) { double('resolver') }
      before(:each) { Berkshelf::Resolver.stub(:new) { resolver } }

      it "resolves the Berksfile" do
        resolver.should_receive(:resolve).and_return([double('cached_cookbook_one'), double('cached_cookbook_two')])
        solution = subject.resolve
        solution.should have(2).items
      end
    end

    describe '#install' do
      context 'is deprecated' do
        before { ::Berkshelf::Installer.stub(:install) }
        after { subject.install }

        it 'prints a deprecation warning' do
          ::Berkshelf.ui.should_receive(:deprecated)
        end

        it 'calls Berkshelf::Installer.install' do
          ::Berkshelf::Installer.should_receive(:install).once
        end
      end
    end

    describe '#update' do
      context 'is deprecated' do
        before { ::Berkshelf::Updater.stub(:update) }
        after { subject.update }

        it 'prints a deprecation warning' do
          ::Berkshelf.ui.should_receive(:deprecated)
        end

        it 'calls Berkshelf::Updater.update' do
          ::Berkshelf::Updater.should_receive(:update).once
        end
      end
    end

    describe "#load" do
      it "reads the content of a Berksfile and adds the sources to the Shelf" do
        subject.load(content)

        ['ntp', 'mysql', 'nginx', 'ssh_known_hosts2'].each do |name|
          subject.should have_source(name)
        end
      end

      it "returns an instance of Berksfile" do
        subject.load(content).should be_a(Berksfile)
      end

      it 'raises a BerksfileReadError when the content is invalid' do
        expect {
          subject.load("not_a_method 'foo'")
        }.to raise_error(::Berkshelf::BerksfileReadError)
      end
    end

    describe "#add_source" do
      let(:name) { "cookbook_one" }
      let(:constraint) { "= 1.2.0" }
      let(:location) { { site: "http://site" } }

      before(:each) do
        subject.add_source(name, constraint, location)
      end

      it "adds new cookbook source to the list of sources" do
        subject.sources.should have(1).source
      end

      it "adds a cookbook source with a 'name' of the given name" do
        subject.sources.first.name.should eql(name)
      end

      it "adds a cookbook source with a 'version_constraint' of the given constraint" do
        subject.sources.first.version_constraint.to_s.should eql(constraint)
      end

      it "raises DuplicateSourceDefined if multiple sources of the same name are found" do
        lambda {
          subject.add_source(name)
        }.should raise_error(DuplicateSourceDefined)
      end
    end

    describe '#remove_source' do
      let(:sources) { subject.instance_variable_get(:@sources) }

      it 'calls #to_s on the source' do
        source_one.should_receive(:to_s)
        subject.remove_source(source_one)
      end

      it 'removes the item from the sources list' do
        sources.should_receive(:delete).with(source_one.to_s)
        subject.remove_source(source_one)
      end
    end

    describe '#[]' do
      let(:sources) { subject.instance_variable_get(:@sources) }

      it 'delegates to the sources' do
        sources.should_receive(:[]).with('my_cookbook')
        subject['my_cookbook']
      end
    end

    describe '#lockfile' do
       it 'returns the lockfile if one exists' do
        ::Berkshelf::Lockfile.stub(:load).and_return(true)
        ::Berkshelf::Lockfile.should_receive(:load).with('Berksfile.lock')

        subject.lockfile
      end

      it "returns a new lockfile if one doesn't exist" do
        ::Berkshelf::Lockfile.stub(:load).and_raise(::Berkshelf::LockfileNotFound)
        ::Berkshelf::Lockfile.should_receive(:new).with([], { berksfile: anything() })

        subject.lockfile
      end
    end

    describe "#add_location" do
      let(:type) { :site }
      let(:value) { double('value') }
      let(:options) { double('options') }

      it "delegates 'add_location' to the downloader" do
        subject.downloader.should_receive(:add_location).with(type, value, options)

        subject.add_location(type, value, options)
      end
    end
  end
end
