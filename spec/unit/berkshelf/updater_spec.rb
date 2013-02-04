require 'spec_helper'

module Berkshelf
  describe Updater do
    let(:berksfile) { double('berksfile') }
    let(:lockfile) { double('lockfile') }
    let(:sources) { double('sources') }
    let(:options) { double('options') }

    subject { ::Berkshelf::Updater.new(options) }

    #
    # Class Methods
    #
    describe '.update' do
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

    #
    # Instance Methods
    #
    describe '#initialize' do
      before do
        ::Berkshelf::Updater.any_instance.stub(:validate_options!).and_return(true)
        ::Berkshelf::Updater.any_instance.stub(:ensure_berksfile!).and_return(true)

        ::Berkshelf::Updater.any_instance.stub(:options).and_return(options)
        berksfile.stub(:sources).and_return(sources)

        ::Berkshelf::Updater.any_instance.stub(:lockfile).and_return(lockfile)
        lockfile.stub(:sources).and_return(sources)

        ::Berkshelf::Updater.any_instance.stub(:filter).and_return([])

        options.should_receive(:delete).with(:cookbooks)
        options.should_receive(:delete).with(:only)
        options.should_receive(:delete).with(:except)

        ::Berkshelf::Installer.should_receive(:install).with(options)
      end

      after do
        subject.update
      end

      context 'with no options' do
        before do
          options.stub(:empty?).and_return(true)
        end

        context 'with no locked sources' do
          it 'unsets the sources and unlocks the sha' do
            lockfile.should_not_receive(:sources)
            lockfile.should_receive(:update).with([])
            lockfile.should_receive(:sha=).with(nil)
            lockfile.should_receive(:save).with(no_args())
          end
        end

        context 'with locked sources' do
          let(:sources) { [double('cookbook_source'), double('cookbook_source')] }

          before do
            lockfile.stub(:sources).and_return(sources)
          end

          it 'unsets the sources and unlocks the sha' do
            lockfile.should_not_receive(:sources)
            lockfile.should_receive(:update).with([])
            lockfile.should_receive(:sha=).with(nil)
            lockfile.should_receive(:save).with(no_args())
          end
        end
      end

      context 'with options' do
        before do
          options.stub(:empty?).and_return(false)
        end

        context 'with no locked sources' do
          before do
            sources.stub(:-).and_return([])
          end

          it 'unsets the sources and unlocks the sha' do
            lockfile.should_receive(:sources).with(no_args())
            lockfile.should_receive(:update).with([])
            lockfile.should_receive(:sha=).with(nil)
            lockfile.should_receive(:save).with(no_args())
          end
        end

        context 'with locked sources' do
          let(:sources) { [double('cookbook_source'), double('cookbook_source')] }

          before do
            lockfile.stub(:sources).and_return(sources)
            sources.stub(:-).and_return(sources)
          end

          it 'sets the sources and unlocks the sha' do
            lockfile.should_receive(:sources).with(no_args())
            lockfile.should_receive(:update).with(sources)
            lockfile.should_receive(:sha=).with(nil)
            lockfile.should_receive(:save).with(no_args())
          end
        end
      end

    end
  end
end
