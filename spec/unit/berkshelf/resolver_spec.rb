require 'spec_helper'

describe Berkshelf::Resolver, :chef_server, vcr: { record: :new_episodes, serialize_with: :yaml } do
  let(:downloader ) { Berkshelf::Downloader.new(Berkshelf.cookbook_store) }
  let(:berksfile) { double(downloader: downloader, filepath: '/foo/bar') }
  let(:dependency) do
    double('dependency',
      name: 'mysql',
      version_constraint: Solve::Constraint.new('= 1.2.4'),
      downloaded?: true,
      cached_cookbook: double('mysql-cookbook',
        name: 'mysql-1.2.4',
        cookbook_name: 'mysql',
        version: '1.2.4',
        dependencies: { "nginx" => ">= 0.1.0" }
      ),
      location: double('location', validate_cached: true)
    )
  end

  describe '.initialize' do
    it 'adds the specified dependencies to the dependencies hash' do
      resolver = Berkshelf::Resolver.new(berksfile, dependencies: [dependency], skip_dependencies: true)
      expect(resolver).to have_dependency(dependency.name)
    end

    it 'does not add dependencies if skipped' do
      resolver = Berkshelf::Resolver.new(berksfile, dependencies: [dependency], skip_dependencies: true)
      expect(resolver).to_not have_dependency('nginx')
    end

    it 'adds the dependencies of the dependency as dependencies' do
      resolver = Berkshelf::Resolver.new(berksfile, dependencies: [dependency])
      expect(resolver).to have_dependency('nginx')
    end
  end

  subject { Berkshelf::Resolver.new(berksfile) }

  describe '#add_dependency' do
    let(:package_version) { double('package-version', dependencies: Array.new) }

    it 'adds the dependency to the instance of resolver' do
      subject.add_dependency(dependency, false)
      expect(subject.dependencies).to include(dependency)
    end

    it 'adds an artifact of the same name of the dependency to the graph' do
      subject.graph.should_receive(:artifacts).with(dependency.name, dependency.cached_cookbook.version)

      subject.add_dependency(dependency, false)
    end

    it 'adds the dependencies of the dependency as packages to the graph' do
      subject.should_receive(:add_recursive_dependencies).with(dependency)

      subject.add_dependency(dependency)
    end

    it 'raises a DuplicateDependencyDefined exception if a dependency of the same name is added' do
      subject.should_receive(:has_dependency?).with(dependency).and_return(true)

      expect {
        subject.add_dependency(dependency)
      }.to raise_error(Berkshelf::DuplicateDependencyDefined)
    end

    context 'when include_dependencies is false' do
      it 'does not try to include_dependencies' do
        subject.should_not_receive(:add_recursive_dependencies)

        subject.add_dependency(dependency, false)
      end
    end
  end

  describe '#get_dependency' do
    before { subject.add_dependency(dependency, false) }

    context 'given a string representation of the dependency to retrieve' do
      it 'returns the dependency of the same name' do
        expect(subject.get_dependency(dependency.name)).to eq(dependency)
      end
    end
  end

  describe '#has_dependency?' do
    before { subject.add_dependency(dependency, false) }

    it 'returns true if the dependency exists' do
      expect(subject.has_dependency?(dependency.name)).to be_true
    end

    it 'returns false if the dependency does not exist' do
      expect(subject.has_dependency?('non-existent')).to be_false
    end
  end

  describe '#to_s' do
    it 'includes the berksfile path' do
      expect(subject.to_s).to eq("#<#{described_class} berksfile: #{subject.berksfile.filepath}>")
    end
  end

  describe '#inspect' do
    before { subject.stub(:dependencies).and_return([double(name_and_version: 'foo (~> 1.0.0)'), double(name_and_version: 'bar (< 1.0.0)')]) }

    it 'includes the dependencies' do
      expect(subject.inspect).to eq("#<#{described_class} berksfile: #{subject.berksfile.filepath}, sources: [#{subject.dependencies.map(&:name_and_version).join(', ')}]>")
    end
  end
end
