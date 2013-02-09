require 'spec_helper'

describe Berkshelf::Updater do
  let(:berksfile) { double('berksfile', lockfile: lockfile) }
  let(:lockfile) { double('lockfile', sources: sources) }
  let(:sources) { Array.new }
  let(:options) do
    Hash.new
  end

  describe "ClassMethods" do
    describe "::update" do
      let(:instance) { double('instance') }

      before do
        ::Berkshelf::Updater.stub(:new).and_return(instance)
      end

      it 'creates a new instance' do
        ::Berkshelf::Updater.should_receive(:new).with(options)
        instance.should_receive(:update)
        ::Berkshelf::Updater.update(options)
      end
    end
  end

  subject { described_class.new(berksfile) }

  describe "#update" do
    before do
      Berkshelf::Installer.should_receive(:install).with(berksfile, options)
    end

    after do
      subject.update(options)
    end

    context 'with no options' do
      let(:options) { Hash.new }

      context 'with no locked sources' do
        it 'unsets the sources and unlocks the sha' do
          lockfile.should_receive(:update).with(sources)
          lockfile.should_receive(:sha=).with(nil)
          lockfile.should_receive(:save).with(no_args())
        end
      end

      context 'with locked sources' do
        let(:sources) { [ double('cookbook_source'), double('cookbook_source') ] }

        before do
          lockfile.stub(:sources).and_return(sources)
        end

        it 'unsets the sources and unlocks the sha' do
          lockfile.should_receive(:update).with([])
          lockfile.should_receive(:sha=).with(nil)
          lockfile.should_receive(:save).with(no_args())
        end
      end
    end

    context 'with options' do
      context 'with no locked sources' do
        before do
          sources.stub(:-).and_return([])
        end

        it 'unsets the sources and unlocks the sha' do
          lockfile.should_receive(:update).with(sources)
          lockfile.should_receive(:sha=).with(nil)
          lockfile.should_receive(:save).with(no_args())
        end
      end

      context 'with locked sources' do
        let(:sources) { [ double('cookbook_source'), double('cookbook_source') ] }

        before do
          lockfile.stub(:sources).and_return(sources)
        end

        it 'sets the sources and unlocks the sha' do
          lockfile.should_receive(:update).with(sources)
          lockfile.should_receive(:sha=).with(nil)
          lockfile.should_receive(:save)
        end
      end
    end
  end
end
