require 'spec_helper'

describe Berkshelf::Installer do
  let(:berksfile) { double('berksfile') }
  subject { described_class.new(berksfile) }

  describe "#build_universe" do
    let(:source_one) { double('one') }
    let(:source_two) { double('two') }
    let(:sources) { [ source_one, source_two ] }

    before { berksfile.stub(sources: sources) }

    it "sends the message #universe on each source" do
      source_one.should_receive(:universe)
      source_two.should_receive(:universe)

      subject.build_universe
    end
  end

  describe "#run" do
    let(:resolver) { double('resolver') }
    let(:lockfile) { double('lockfile') }

    let(:cached_cookbooks) { [double('cached_one'), double('cached_two')] }
    let(:dependencies) { [] }

    before do
      Berkshelf::Resolver.stub(:new).and_return(resolver)
      Berkshelf::Lockfile.stub(:new).and_return(lockfile)

      berksfile.stub(lockfile: lockfile)
      berksfile.stub(dependencies: [])
      berksfile.stub(sources: [])

      lockfile.stub(dependencies: [])
      lockfile.stub(:update)
    end

    context 'when a lockfile is not present' do
      it 'returns the result from sending the message resolve to resolver' do
        resolver.should_receive(:resolve).and_return(cached_cookbooks)
        expect(subject.run).to eql(cached_cookbooks)
      end

      it 'sets a value for self.cached_cookbooks equivalent to the return value' do
        resolver.should_receive(:resolve).and_return(cached_cookbooks)
        subject.run

        expect(subject.cached_cookbooks).to eql(cached_cookbooks)
      end

      it 'creates a new resolver and finds a solution by calling resolve on the resolver' do
        resolver.should_receive(:resolve)
        subject.run
      end

      it 'writes a lockfile with the resolvers dependencies' do
        resolver.should_receive(:resolve)
        lockfile.should_receive(:update).with([])

        subject.run
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
        subject.run(except: [:skip_me])
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
        subject.run(only: [:skip_me])
      end
    end
  end

  describe "#resolve" do
    let(:resolver) { double('resolver') }
    let(:dependencies) { double('dependencies') }

    it "instantiates and delegates to an instance of Resolver" do
      Berkshelf::Resolver.should_receive(:new).with(berksfile, dependencies).and_return(resolver)
      resolver.should_receive(:resolve)

      subject.resolve(dependencies)
    end
  end

  describe "#verify_licenses!" do
    pending
  end
end
