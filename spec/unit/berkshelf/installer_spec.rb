require 'spec_helper'

describe Berkshelf::Installer do
  let(:berksfile) { double('berksfile') }
  let(:lockfile) { double('lockfile') }
  let(:options) { double('options') }
  let(:resolver) { double('resolver') }

  let(:source_1) { double('cookbook_source@build-essential') }
  let(:source_2) { double('cookbook_source@chef-client') }
  let(:locked_1) { double('locked_cookbook_source@build-essential-1.1.0') }
  let(:locked_2) { double('locked_cookbook_source@chef-client-0.0.4') }

  let(:version_constraint) { double('version_constraint') }

  let(:sources) { [source_1, source_2] }
  let(:locked_sources) { [locked_1, locked_2] }

  describe "ClassMethods" do
    subject { described_class }

    describe "::vendor" do
      let(:cached_cookbooks) { [] }
      let(:tmpdir) { Dir.mktmpdir(nil, tmp_path) }

      it "returns the expanded filepath of the vendor directory" do
        subject.vendor(cached_cookbooks, tmpdir).should eql(tmpdir)
      end

      context "with a chefignore" do
        before(:each) do
          File.stub(:exists?).and_return(true)
          ::Chef::Cookbook::Chefignore.any_instance.stub(:remove_ignores_from).and_return(['metadata.rb'])
        end

        it "finds a chefignore file" do
          ::Chef::Cookbook::Chefignore.should_receive(:new).with(File.expand_path('chefignore'))
          subject.vendor(cached_cookbooks, tmpdir)
        end

        it "removes files in chefignore" do
          cached_cookbooks = [ Berkshelf::CachedCookbook.from_path(fixtures_path.join('cookbooks/example_cookbook')) ]
          FileUtils.should_receive(:cp_r).with(['metadata.rb'], anything()).exactly(1).times
          FileUtils.should_receive(:cp_r).with(anything(), anything(), anything()).once
          subject.vendor(cached_cookbooks, tmpdir)
        end
      end
    end

    describe "::install" do
      let(:berksfile) { double('berksfile') }

      it "creates a new instance and calls #install" do
        instance = double('installer')
        subject.should_receive(:new).with(berksfile).and_return(instance)
        instance.should_receive(:install).with(options)

        subject.install(berksfile, options)
      end
    end
  end

  subject { ::Berkshelf::Installer.new(options) }

  before do
    ::Berkshelf::Installer.any_instance.stub(:validate_options!).and_return(true)
    ::Berkshelf::Installer.any_instance.stub(:ensure_berkshelf_directory!).and_return(true)
    ::Berkshelf::Installer.any_instance.stub(:ensure_berksfile_content!).and_return(true)
    ::Berkshelf::Installer.any_instance.stub(:ensure_berksfile!).and_return(true)
    ::Berkshelf::Installer.any_instance.stub(:options).and_return(options)

    ::Berkshelf::Installer.any_instance.stub(:berksfile).and_return(berksfile)
    berksfile.stub(:sources).and_return(sources)
    berksfile.stub(:sha).and_return('abc123')

    ::Berkshelf::Installer.any_instance.stub(:lockfile).and_return(lockfile)
    lockfile.stub(:sources).and_return(locked_sources)
    lockfile.stub(:sha).and_return('abc123')

    ::Berkshelf::Installer.any_instance.stub(:filter).and_return(sources)

    ::Berkshelf::Resolver.stub(:new).with(any_args()).and_return(resolver)
    resolver.stub(:resolve).and_return(sources)
    resolver.stub(:sources).and_return(sources)

    options.stub(:[]).with(:path).and_return(nil)

    source_1.stub(:name).and_return('build-essential')
    source_1.stub(:version_constraint).and_return(version_constraint)

    source_2.stub(:name).and_return('chef-client')
    source_2.stub(:version_constraint).and_return(version_constraint)

    locked_1.stub(:name).and_return('build-essential')
    locked_1.stub(:locked_version).and_return('1.1.0')
    locked_1.stub(:version).and_return('1.1.0')

    locked_2.stub(:name).and_return('chef-client')
    locked_2.stub(:locked_version).and_return('0.0.4')
    locked_2.stub(:version).and_return('0.0.4')

    version_constraint.stub(:satisfies?).with(any_args()).and_return(true)
  end

  describe '#initialize' do
    context 'with an unchanged Berksfile' do
      before do
        berksfile.stub(:sha).and_return('abc123')
        lockfile.stub(:sha).and_return('abc123')

        ::Berkshelf::Installer.any_instance.stub(:resolve).with(locked_sources).and_return([sources, locked_sources])
      end

      it 'uses the lockfile sources' do
        lockfile.should_receive(:update).with(locked_sources)
        lockfile.should_receive(:sha=).with('abc123')
        lockfile.should_receive(:save)
        subject.install
      end
    end

    context 'with a changed Berskfile' do
      before do
        berksfile.stub(:sha).and_return('abc123')
        lockfile.stub(:sha).and_return('def456')

        ::Berkshelf::Installer.any_instance.stub(:resolve).with(locked_sources).and_return([sources, locked_sources])
      end

      it 'builds a sources diff' do
        lockfile.should_receive(:update).with(locked_sources)
        lockfile.should_receive(:sha=).with('abc123')
        lockfile.should_receive(:save)
        subject.install
      end

      context 'with conflicting constraints' do
        before do
          version_constraint.stub(:satisfies?).with(any_args()).and_return(false)
        end

        it 'raises a ::Bershelf::OutdatedCookbookSource' do
          expect { subject.install }.to raise_error(::Berkshelf::OutdatedCookbookSource)
        end
      end

      context 'with unlocked sources' do
        before do
          locked_sources.stub(:find).with(any_args()).and_return(nil)
          ::Berkshelf::Installer.any_instance.stub(:resolve).with(sources).and_return([sources, locked_sources])
        end

        it 'returns just the sources' do
          lockfile.should_receive(:update).with(locked_sources)
          lockfile.should_receive(:sha=).with('abc123')
          lockfile.should_receive(:save)
          subject.install
        end
      end

      context 'with the --path option' do
        before do
          options.stub(:[]).with(:path).and_return('/tmp')
          berksfile.stub(:sha).and_return('abc123')
          lockfile.stub(:sha).and_return('abc123')
          ::Berkshelf::Installer.any_instance.stub(:vendor).and_return(nil)
          ::Berkshelf::Installer.any_instance.stub(:resolve).with(locked_sources).and_return([sources, locked_sources])
        end

        it 'vendors the cookbooks' do
          lockfile.should_receive(:update).with(locked_sources)
          lockfile.should_receive(:sha=).with('abc123')
          lockfile.should_receive(:save)
          subject.install
        end
      end
    end
  end
end
