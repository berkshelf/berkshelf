require 'spec_helper'

module Berkshelf
  describe Shell do
    let(:stdout) { double('stdout', tty?: true) }
    let(:stderr) { double('stderr') }

    before do
      allow_any_instance_of(described_class).to receive(:stdout)
        .and_return(stdout)

      allow_any_instance_of(described_class).to receive(:stderr)
        .and_return(stderr)
    end

    describe '#mute!' do
      it 'sets @mute to true' do
        subject.mute!
        expect(subject.instance_variable_get(:@mute)).to be(true)
      end
    end

    describe '#unmute!' do
      it 'sets @mute to false' do
        subject.unmute!
        expect(subject.instance_variable_get(:@mute)).to be(false)
      end
    end

    describe '#say' do
      context 'when quiet?' do
        before do
          allow(subject).to receive(:quiet?).and_return(true)
        end

        it 'does not output anything', :not_supported_on_windows do
          expect(stdout).to_not receive(:print)
          expect(stdout).to_not receive(:puts)
          subject.say 'message'
        end
      end

      context 'with not quiet?' do
        before do
          allow(subject).to receive(:quiet?).and_return(false)
        end

        it 'prints to stdout' do
          expect(stdout).to receive(:print).once
          expect(stdout).to receive(:flush).once
          subject.say 'message'
        end
      end
    end

    describe '#say_status' do
      context 'when quiet?' do
        before do
          allow(subject).to receive(:quiet?).and_return(true)
        end

        it 'does not output anything' do
          expect(stdout).to_not receive(:print)
          expect(stdout).to_not receive(:puts)
          subject.say_status 5, 'message'
        end
      end

      context 'with not quiet?' do
        before do
          allow(subject).to receive(:quiet?).and_return(false)
        end

        it 'prints to stdout' do
          expect(stdout).to receive(:print).once
          expect(stdout).to receive(:flush).once
          subject.say_status 5, 'message'
        end
      end
    end

    describe '#warn' do
      context 'when quiet?' do
        before do
          allow(subject).to receive(:quiet?).and_return(true)
        end

        it 'does not output anything' do
          expect(stdout).to_not receive(:print)
          expect(stdout).to_not receive(:puts)
          subject.warn 'warning'
        end
      end

      context 'with not quiet?' do
        before do
          allow(subject).to receive(:quiet?).and_return(false)
        end

        it 'calls #say with yellow coloring' do
          expect(stdout).to receive(:print).once
          expect(stdout).to receive(:flush).once
          subject.warn 'warning'
        end
      end
    end

    context '#error' do
      context 'when quiet?' do
        before do
          allow(subject).to receive(:quiet?).and_return(true)
        end

        it "outputs an error message", :not_supported_on_windows do
          expect(stderr).to receive(:puts)
          subject.error 'error!'
        end
      end

      context 'with not quiet?' do
        before do
          allow(subject).to receive(:quiet?).and_return(false)
        end

        it 'prints to stderr' do
          expect(stderr).to receive(:puts)
            .with(windows? ? "error!" : "\e[31merror!\e[0m")
          subject.error 'error!'
        end
      end
    end
  end
end
