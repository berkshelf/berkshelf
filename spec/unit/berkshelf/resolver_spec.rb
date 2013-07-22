require 'spec_helper'

describe Berkshelf::Resolver, :chef_server, vcr: {record: :new_episodes, serialize_with: :yaml} do
  let(:downloader) { Berkshelf::Downloader.new(Berkshelf.cookbook_store) }
  let(:berksfile) { double(downloader: downloader) }
  let(:source) do
    double('source',
      name: 'mysql',
      version_constraint: Solve::Constraint.new('= 1.2.4'),
      :version_constraint= => nil,
      locked_version: '1.2.4',
      downloaded?: true,
      cached_cookbook: double('mysql-cookbook',
        name: 'mysql-1.2.4',
        cookbook_name: 'mysql',
        version: '1.2.4',
        dependencies: {"nginx" => ">= 0.1.0"}
      ),
      location: double('location', validate_cached: true)
    )
  end

  describe '.initialize' do
    it 'adds the specified sources to the sources hash' do
      resolver = Berkshelf::Resolver.new(berksfile, sources: [source], skip_dependencies: true)
      expect(resolver).to have_source(source.name)
    end

    it 'does not add dependencies if skipped' do
      resolver = Berkshelf::Resolver.new(berksfile, sources: [source], skip_dependencies: true)
      expect(resolver).to_not have_source('nginx')
    end

    it 'adds the dependencies of the source as sources' do
      resolver = Berkshelf::Resolver.new(berksfile, sources: [source])
      expect(resolver).to have_source('nginx')
    end

    context 'location is not set' do
      before(:each) do
        source.stub(:location) { nil }
      end

      it 'does not raise' do
        expect { Berkshelf::Resolver.new(berksfile, sources: [source], skip_dependencies: true) }.to_not raise_error
      end
    end
  end


  subject { Berkshelf::Resolver.new(berksfile) }

  describe '#add_source' do
    let(:package_version) { double('package-version', dependencies: Array.new) }

    it 'adds the source to the instance of resolver' do
      subject.add_source(source, false)
      expect(subject.sources).to include(source)
    end

    it 'adds an artifact of the same name of the source to the graph' do
      subject.graph.should_receive(:artifacts).with(source.name, source.cached_cookbook.version)

      subject.add_source(source, false)
    end

    it 'adds the dependencies of the source as packages to the graph' do
      subject.should_receive(:add_source_dependencies).with(source)

      subject.add_source(source)
    end

    it 'raises a DuplicateSourceDefined exception if a source of the same name is added' do
      subject.should_receive(:has_source?).with(source).and_return(true)

      expect {
        subject.add_source(source)
      }.to raise_error(Berkshelf::DuplicateSourceDefined)
    end

    context 'when include_dependencies is false' do
      it 'does not try to include_dependencies' do
        subject.should_not_receive(:add_source_dependencies)

        subject.add_source(source, false)
      end
    end
  end

  describe '#get_source' do
    before { subject.add_source(source, false) }

    context 'given a string representation of the source to retrieve' do
      it 'returns the source of the same name' do
        expect(subject.get_source(source.name)).to eq(source)
      end
    end
  end

  describe '#has_source?' do
    before { subject.add_source(source, false) }

    it 'returns true if the source exists' do
      expect(subject.has_source?(source.name)).to be_true
    end

    it 'returns false if the source does not exist' do
      expect(subject.has_source?('non-existent')).to be_false
    end
  end
end
