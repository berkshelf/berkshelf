require 'spec_helper'

module Berkshelf
  describe Berksfile do
    let(:content) do
<<-EOF
cookbook 'ntp', '<= 1.0.0'
cookbook 'mysql'
cookbook 'nginx', '< 0.101.2'
cookbook 'ssh_known_hosts2', :git => 'https://github.com/erikh/chef-ssh_known_hosts2.git'
EOF
    end

    describe "ClassMethods" do
      subject { Berksfile }

      describe "::from_file" do
        let(:cookbook_file) { fixtures_path.join('lockfile_spec', 'with_lock', 'Berksfile') }

        it "reads a Berksfile and returns an instance Berksfile" do
          subject.from_file(cookbook_file).should be_a(Berksfile)
        end

        context "when Berksfile does not exist at given path" do
          let(:bad_path) { tmp_path.join("thisdoesnotexist") }

          it "raises BerksfileNotFound" do
            lambda {
              subject.from_file(bad_path)
            }.should raise_error(BerksfileNotFound)
          end
        end
      end

      describe "::vendor" do
        let(:cached_cookbooks) { [] }
        let(:tmpdir) { Dir.mktmpdir(nil, tmp_path) }

        it "returns the expanded filepath of the vendor directory" do
          subject.vendor(cached_cookbooks, tmpdir).should eql(tmpdir)
        end

        context "with a chefignore" do
          before(:each) do
            File.stub(:exists?).and_return(true)
            Berkshelf::Chef::Cookbook::Chefignore.any_instance.stub(:remove_ignores_from).and_return(['metadata.rb'])
          end

          it "finds a chefignore file" do
            Berkshelf::Chef::Cookbook::Chefignore.should_receive(:new).with(File.expand_path('chefignore'))
            subject.vendor(cached_cookbooks, tmpdir)
          end

          it "removes files in chefignore" do
            cached_cookbooks = [ CachedCookbook.from_path(fixtures_path.join('cookbooks/example_cookbook')) ]
            FileUtils.should_receive(:cp_r).with(['metadata.rb'], anything()).exactly(1).times
            FileUtils.should_receive(:cp_r).with(anything(), anything(), anything()).once
            subject.vendor(cached_cookbooks, tmpdir)
          end
        end
      end
    end

    let(:source_one) { double('source_one', name: "nginx") }
    let(:source_two) { double('source_two', name: "mysql") }

    subject { Berksfile.new(tmp_path.join("Berksfile")) }

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

    describe "#install" do
      let(:resolver) { double('resolver') }
      before(:each) { Berkshelf::Resolver.stub(:new) { resolver } }

      context "when a lockfile is not present" do
        before(:each) do
          subject.should_receive(:lockfile_present?).and_return(false)
          resolver.should_receive(:sources).and_return([])
        end

        let(:cached_cookbooks) do
          [
            double('cached_one'),
            double('cached_two')
          ]
        end

        it "returns the result from sending the message resolve to resolver" do
          resolver.should_receive(:resolve).and_return(cached_cookbooks)

          subject.install.should eql(cached_cookbooks)
        end

        it "sets a value for self.cached_cookbooks equivalent to the return value" do
          resolver.should_receive(:resolve).and_return(cached_cookbooks)
          subject.install

          subject.cached_cookbooks.should eql(cached_cookbooks)
        end

        it "creates a new resolver and finds a solution by calling resolve on the resolver" do
          resolver.should_receive(:resolve)

          subject.install
        end

        it "writes a lockfile with the resolvers sources" do
          resolver.should_receive(:resolve)
          subject.should_receive(:write_lockfile).with([])

          subject.install
        end
      end

      context "when a lockfile is present" do
        before(:each) { subject.should_receive(:lockfile_present?).and_return(true) }

        it "does not write a new lock file" do
          resolver.should_receive(:resolve)
          subject.should_not_receive(:write_lockfile)

          subject.install
        end
      end

      context "when a value for :path is given" do
        before(:each) { resolver.should_receive(:resolve) }

        it "sends the message 'vendor' to Berksfile with the value for :path" do
          path = double('path')
          subject.class.should_receive(:vendor).with(subject.cached_cookbooks, path)

          subject.install(path: path)
        end
      end

      context "when a value for :except is given" do
        before(:each) { resolver.should_receive(:resolve) }

        it "filters the sources and gives the results to the Resolver initializer" do
          filtered = double('sources')
          subject.should_receive(:sources).with(except: [:skip_me]).and_return(filtered)
          Resolver.should_receive(:new).with(anything, sources: filtered)

          subject.install(except: [:skip_me])
        end
      end

      context "when a value for :only is given" do
        before(:each) { resolver.should_receive(:resolve) }

        it "filters the sources and gives the results to the Resolver initializer" do
          filtered = double('sources')
          subject.should_receive(:sources).with(only: [:skip_me]).and_return(filtered)

          subject.install(only: [:skip_me])
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
