require 'spec_helper'

module Berkshelf
  describe Berksfile do
    describe "ClassMethods" do
      subject { Berksfile }

      let(:content) do
<<-EOF
cookbook 'ntp', '<= 1.0.0'
cookbook 'mysql'
cookbook 'nginx', '< 0.101.2'
cookbook 'ssh_known_hosts2', :git => 'https://github.com/erikh/chef-ssh_known_hosts2.git'
EOF
      end

      describe "#read" do
        it "reads the content of a Berksfile and adds the sources to the Shelf" do
          cbfile = subject.read(content)

          ['ntp', 'mysql', 'nginx', 'ssh_known_hosts2'].each do |name|
            cbfile.should have_source(name)
          end
        end

        it "returns an instance of Berksfile" do
          subject.read(content).should be_a(Berksfile)
        end
      end

      describe "#from_file" do
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

      describe "#filter_sources" do
        context "given one of the sources is a member of one of the excluded groups" do
          let(:excluded_groups) { [:nautilus, :skarner] }
          let(:source_one) { double('source_one') }
          let(:source_two) { double('source_two') }

          before(:each) do
            source_one.stub(:groups) { [:nautilus] }
            source_two.stub(:groups) { [:riven] }
            @sources = [source_one, source_two]
          end

          it "returns an array without sources that were members of the excluded groups" do
            result = subject.filter_sources(@sources, excluded_groups)

            result.should_not include(source_one)
          end

          it "does not remove sources that were not a member of the excluded groups" do
            result = subject.filter_sources(@sources, excluded_groups)

            result.should include(source_two)
          end
        end
      end
    end

    let(:source_one) { double('source_one', name: "nginx") }
    let(:source_two) { double('source_two', name: "mysql") }

    subject do
      cbf = Berksfile.new
      cbf.add_source(source_one)
      cbf.add_source(source_two)
      cbf
    end

    describe "#sources" do
      it "returns all CookbookSources added to the instance of Berksfile" do
        result = subject.sources

        result.should have(2).items
        result.should include(source_one)
        result.should include(source_two)
      end

      context "given the option :exclude" do
        it "filters the sources before returning them" do
          subject.class.should_receive(:filter_sources).with(subject.sources, :nautilus)

          subject.sources(exclude: :nautilus)
        end
      end
    end

    describe "#groups" do
      before(:each) do
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
        subject.groups[:nautilus].should include(source_one)
        subject.groups[:nautilus].should include(source_two)
        subject.groups[:riven].should_not include(source_one)
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

      context "when given a value for :shims pointing to a valid path" do
        let(:cached_one) { double('cached_one', cookbook_name: 'nginx', path: tmp_path.join("fake_berkshelf", "nginx-0.100.5")) }
        let(:cached_two) { double('cached_two', cookbook_name: 'example_cookbook', path: tmp_path.join("fake_berkshelf", "example_cookbook-0.5.0")) }
        let(:shims_path) { tmp_path.join("cookbook_shims") }

        before(:each) do
          FileUtils.mkdir_p(cached_one.path)
          FileUtils.mkdir_p(cached_two.path)
          FileUtils.mkdir_p(shims_path.to_s)
          resolver.stub(:resolve).and_return([cached_one, cached_two])
        end

        it "writes a directory at the given path" do
          subject.install(shims: shims_path)

          shims_path.should exist
          shims_path.should be_directory
        end

        it "writes a symlink of the name of each source within the given directory" do
          subject.install(shims: shims_path)

          shims_path.join(cached_one.cookbook_name).should exist
          shims_path.join(cached_two.cookbook_name).should exist
        end
      end
    end
  end
end
