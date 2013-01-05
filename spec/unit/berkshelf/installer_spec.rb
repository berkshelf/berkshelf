require 'spec_helper'

module Berkshelf
  describe Installer do

    let(:resolver) { double('resolver') }
    let(:berksfile) { double('berksfile') }
    let(:lockfile) { double('lockfile') }

    before do
      Installer.should_receive(:ensure_berkshelf_directory!).and_return(true)
      Installer.should_receive(:ensure_berksfile!).and_return(true)
      Installer.should_receive(:ensure_berksfile_content!).and_return(true)
      Installer.should_receive(:validate_options!).and_return(true)
      Installer.should_receive(:options).and_return({})
      Installer.should_receive(:lockfile).and_return(lockfile)
      Installer.should_receive(:berksfile).and_return(berksfile)

      Berkshelf::Resolver.stub(:new) { resolver }
    end

    context 'with a lockfile' do
      before do
        lockfile.should_receive(:sources).and_return([])
        lockfile.should_receive(:sha).and_return('sha123')
      end

      it 'retrieves the sources from the berksfile' do
        berksfile.should_receive(:sources)
        berksfile.should_receive(:sha)
        Installer.install
      end
    end

    # let(:resolver) { double('resolver') }
    # before(:each) { Berkshelf::Resolver.stub(:new) { resolver } }

    # context "when a lockfile is not present" do
    #   before(:each) do
    #     subject.should_receive(:lockfile_present?).and_return(false)
    #     resolver.should_receive(:sources).and_return([])
    #   end

    #   let(:cached_cookbooks) do
    #     [
    #       double('cached_one'),
    #       double('cached_two')
    #     ]
    #   end

    #   it "returns the result from sending the message resolve to resolver" do
    #     resolver.should_receive(:resolve).and_return(cached_cookbooks)

    #     subject.install.should eql(cached_cookbooks)
    #   end

    #   it "sets a value for self.cached_cookbooks equivalent to the return value" do
    #     resolver.should_receive(:resolve).and_return(cached_cookbooks)
    #     subject.install

    #     subject.cached_cookbooks.should eql(cached_cookbooks)
    #   end

    #   it "creates a new resolver and finds a solution by calling resolve on the resolver" do
    #     resolver.should_receive(:resolve)

    #     subject.install
    #   end

    #   it "writes a lockfile with the resolvers sources" do
    #     resolver.should_receive(:resolve)
    #     subject.should_receive(:write_lockfile).with([])

    #     subject.install
    #   end
    # end

    # context "when a lockfile is present" do
    #   before(:each) { subject.should_receive(:lockfile_present?).and_return(true) }

    #   it "does not write a new lock file" do
    #     resolver.should_receive(:resolve)
    #     subject.should_not_receive(:write_lockfile)

    #     subject.install
    #   end
    # end

    # context "when a value for :path is given" do
    #   before(:each) { resolver.should_receive(:resolve) }

    #   it "sends the message 'vendor' to Berksfile with the value for :path" do
    #     path = double('path')
    #     subject.class.should_receive(:vendor).with(subject.cached_cookbooks, path)

    #     subject.install(path: path)
    #   end
    # end

    # context "when a value for :except is given" do
    #   before(:each) { resolver.should_receive(:resolve) }

    #   it "filters the sources and gives the results to the Resolver initializer" do
    #     filtered = double('sources')
    #     subject.should_receive(:sources).with(except: [:skip_me]).and_return(filtered)
    #     Resolver.should_receive(:new).with(anything, sources: filtered)

    #     subject.install(except: [:skip_me])
    #   end
    # end

    # context "when a value for :only is given" do
    #   before(:each) { resolver.should_receive(:resolve) }

    #   it "filters the sources and gives the results to the Resolver initializer" do
    #     filtered = double('sources')
    #     subject.should_receive(:sources).with(only: [:skip_me]).and_return(filtered)

    #     subject.install(only: [:skip_me])
    #   end
    # end

  end
end
