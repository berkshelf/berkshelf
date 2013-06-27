require 'spec_helper'

describe Berkshelf::Installer do
  describe "#run" do
    let(:resolver) { double('resolver') }
    let(:lockfile) { double('lockfile') }

    let(:cached_cookbooks) { [double('cached_one'), double('cached_two')] }
    let(:dependencies) { [dependency_one, dependency_two] }

    before do
      Berkshelf::Resolver.stub(:new).and_return(resolver)
      Berkshelf::Lockfile.stub(:new).and_return(lockfile)

      lockfile.stub(:dependencies).and_return([])

      resolver.stub(:dependencies).and_return([])
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

      it 'writes a lockfile with the resolvers dependencies' do
        resolver.should_receive(:resolve)
        lockfile.should_receive(:update).with([])

        subject.install
      end
    end

    context 'when a value for :path is given' do
      before do
        resolver.should_receive(:resolve)
        resolver.should_receive(:dependencies).and_return([])
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
        resolver.should_receive(:dependencies).and_return([])
        subject.stub(:dependencies).and_return(dependencies)
        subject.stub(:apply_lockfile).and_return(dependencies)
      end

      it 'filters the dependencies and gives the results to the Resolver initializer' do
        subject.should_receive(:dependencies).with(except: [:skip_me]).and_return(dependencies)
        subject.install(except: [:skip_me])
      end
    end

    context 'when a value for :only is given' do
      before do
        resolver.should_receive(:resolve)
        resolver.should_receive(:dependencies).and_return([])
        subject.stub(:dependencies).and_return(dependencies)
        subject.stub(:apply_lockfile).and_return(dependencies)
      end

      it 'filters the dependencies and gives the results to the Resolver initializer' do
        subject.should_receive(:dependencies).with(only: [:skip_me]).and_return(dependencies)
        subject.install(only: [:skip_me])
      end
    end
  end

  describe "#resolve" do
    let(:resolver) { double('resolver') }
    let(:dependencies) { [dependency_one, dependency_two] }
    let(:cached) { [double('cached_one'), double('cached_two')] }

    before { Berkshelf::Resolver.stub(:new).and_return(resolver) }

    it 'resolves the Berksfile' do
      resolver.should_receive(:resolve).and_return(cached)
      resolver.should_receive(:dependencies).and_return(dependencies)

      expect(subject.resolve).to eq({ solution: cached, dependencies: dependencies })
    end
  end
end
