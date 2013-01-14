require 'spec_helper'

module Berkshelf
  describe Updater do
    context '.update' do
      let(:berksfile) { double('berksfile') }
      let(:lockfile) { double('lockfile') }
      let(:sources) { double('sources') }
      let(:options) { double('options') }

      before do
        ::Berkshelf::Command.stub(:validate_options!).and_return(true)
        ::Berkshelf::Command.stub(:ensure_berksfile!).and_return(true)

        ::Berkshelf::Command.stub(:options).and_return(options)
        berksfile.stub(:sources).and_return(sources)

        ::Berkshelf::Command.stub(:lockfile).and_return(lockfile)
        lockfile.stub(:sources).and_return(sources)

        ::Berkshelf::Command.stub(:filter).and_return([])

        ::Berkshelf::Updater.should_receive(:validate_options!).once
        ::Berkshelf::Updater.should_receive(:ensure_berksfile!).once

        options.should_receive(:delete).with(:cookbooks)
        options.should_receive(:delete).with(:only)
        options.should_receive(:delete).with(:except)

        ::Berkshelf::Installer.should_receive(:install).with(options)
      end

      after do
        ::Berkshelf::Updater.update
      end

      context 'with no options' do
        before do
          options.stub(:empty?).and_return(true)
        end

        context 'with no locked sources' do
          it '' do
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

          it '' do
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

          it '' do
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

          it '' do
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
