require 'spec_helper'

describe Berkshelf::Lockfile do
  before do
    subject.stub(:filepath).and_return(fixture) if defined?(fixture)
    subject.parse
  end

  context 'with an old 2.0 lockfile format' do
    let(:fixture) { fixtures_path.join('lockfiles/2.0.lock') }

    it 'does not blow up' do
      expect { subject }.to_not raise_error
    end

    it 'warns the user' do
      expect(Berkshelf.ui).to receive(:warn)
      subject.parse
    end

    it 'sets the dependencies' do
      expect(subject).to have_dependency('apt')
      expect(subject).to have_dependency('jenkins')
      expect(subject).to have_dependency('runit')
      expect(subject).to have_dependency('yum')

      expect(subject.find('apt').version_constraint.to_s).to eq('>= 0.0.0')
      expect(subject.find('jenkins').version_constraint.to_s).to eq('>= 0.0.0')
      expect(subject.find('runit').version_constraint.to_s).to eq('>= 0.0.0')
      expect(subject.find('yum').version_constraint.to_s).to eq('>= 0.0.0')
    end

    it 'sets the graph' do
      graph = subject.graph

      expect(graph).to have_lock('apt')
      expect(graph).to have_lock('jenkins')
      expect(graph).to have_lock('runit')
      expect(graph).to have_lock('yum')

      expect(graph.find('apt').version).to eq('2.3.6')
      expect(graph.find('jenkins').version).to eq('2.0.3')
      expect(graph.find('runit').version).to eq('1.5.8')
      expect(graph.find('yum').version).to eq('3.0.6')
    end
  end

  context 'with a blank lockfile' do
    let(:fixture) { fixtures_path.join('lockfiles/blank.lock') }

    it 'warns the user' do
      expect(Berkshelf.ui).to receive(:warn)
      subject.parse
    end

    it 'sets an empty list of dependencies' do
      expect(subject.dependencies).to be_empty
    end

    it 'sets an empty graph' do
      expect(subject.graph.locks).to be_empty
    end
  end

  context 'with an empty lockfile' do
    let(:fixture) { fixtures_path.join('lockfiles/empty.lock') }

    it 'does not warn the user' do
      expect(Berkshelf.ui).to_not receive(:warn)
      subject.parse
    end

    it 'sets an empty list of dependencies' do
      expect(subject.dependencies).to be_empty
    end

    it 'sets an empty graph' do
      expect(subject.graph.locks).to be_empty
    end
  end

  context 'with real lockfile' do
    let(:fixture) { fixtures_path.join('lockfiles/default.lock') }

    it 'sets the dependencies' do
      expect(subject).to have_dependency('apt')
      expect(subject).to have_dependency('jenkins')

      expect(subject.find('apt').version_constraint.to_s).to eq('~> 2.0')
      expect(subject.find('jenkins').version_constraint.to_s).to eq('~> 2.0')
    end

    it 'sets the graph' do
      graph = subject.graph

      expect(graph).to have_lock('apt')
      expect(graph).to have_lock('build-essential')
      expect(graph).to have_lock('jenkins')
      expect(graph).to have_lock('runit')
      expect(graph).to have_lock('yum')
      expect(graph).to have_lock('yum-epel')

      expect(graph.find('apt').version).to eq('2.3.6')
      expect(graph.find('build-essential').version).to eq('1.4.2')
      expect(graph.find('jenkins').version).to eq('2.0.3')
      expect(graph.find('runit').version).to eq('1.5.8')
      expect(graph.find('yum').version).to eq('3.0.6')
      expect(graph.find('yum-epel').version).to eq('0.2.0')
    end

    it 'sets the graph item dependencies' do
      jenkins = subject.graph.find('jenkins')
      runit = subject.graph.find('runit')

      expect(jenkins.dependencies).to include('apt' => '~> 2.0')
      expect(jenkins.dependencies).to include('runit' => '~> 1.5')
      expect(jenkins.dependencies).to include('yum' => '~> 3.0')

      expect(runit.dependencies).to include('build-essential' => '>= 0.0.0')
      expect(runit.dependencies).to include('yum' => '~> 3.0')
      expect(runit.dependencies).to include('yum-epel' => '>= 0.0.0')
    end
  end
end
