require 'spec_helper'

describe Thor::Base.shell do
  let(:stdout) { double('stdout') }
  let(:stderr) { double('stderr') }

  before do
    described_class.any_instance.stub(:stdout).and_return(stdout)
    described_class.any_instance.stub(:stderr).and_return(stderr)
  end

  describe '#mute!' do
    it 'sets @mute to true' do
      subject.mute!
      expect(subject.instance_variable_get(:@mute)).to be_true
    end
  end

  describe '#unmute!' do
    it 'sets @mute to false' do
      subject.unmute!
      expect(subject.instance_variable_get(:@mute)).to be_false
    end
  end

  describe '#say' do
    context 'when quiet?' do
      before do
        subject.stub(:quiet?).and_return(true)
      end

      it 'does not output anything' do
        stdout.should_not_receive(:puts)
        subject.say 'message'
      end
    end

    context 'with not quiet?' do
      before do
        subject.stub(:quiet?).and_return(false)
      end

      it 'prints to stdout' do
        stdout.should_receive(:puts).with('message').once
        stdout.should_receive(:flush).with(no_args())
        subject.say 'message'
      end
    end
  end

  describe '#say_status' do
    context 'when quiet?' do
      before do
        subject.stub(:quiet?).and_return(true)
      end

      it 'does not output anything' do
        stdout.should_not_receive(:puts)
        subject.say_status 5, 'message'
      end
    end

    context 'with not quiet?' do
      before do
        subject.stub(:quiet?).and_return(false)
      end

      it 'prints to stdout' do
        stdout.should_receive(:puts).with("\e[1m\e[32m           5\e[0m  message")
        stdout.should_receive(:flush).with(no_args())
        subject.say_status 5, 'message'
      end
    end
  end

  describe '#warn' do
    context 'when quiet?' do
      before do
        subject.stub(:quiet?).and_return(true)
      end

      it 'does not output anything' do
        stdout.should_not_receive(:puts)
        subject.warn 'warning'
      end
    end

    context 'with not quiet?' do
      before do
        subject.stub(:quiet?).and_return(false)
      end

      it 'calls #say with yellow coloring' do
        stdout.stub :tty?
        stdout.should_receive(:puts).with("warning")
        stdout.should_receive(:flush).with(no_args())
        subject.warn 'warning'
      end
    end
  end

  describe '#deprecated' do
    it 'prefixes the message with "[DEPRECATED]"' do
      subject.should_receive(:warn).with('[DEPRECATION] That was deprecated!')
      subject.deprecated 'That was deprecated!'
    end
  end

  context '#error' do
    context 'when quiet?' do
      before do
        subject.stub(:quiet?).and_return(true)
      end

      it 'does not output anything' do
        stdout.should_not_receive(:puts)
        subject.error 'error!'
      end
    end

    context 'with not quiet?' do
      before do
        subject.stub(:quiet?).and_return(false)
      end

      it 'prints to stderr' do
        stderr.should_receive(:puts).with("\e[31merror!\e[0m")
        subject.error 'error!'
      end
    end
  end
end
