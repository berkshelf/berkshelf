require 'spec_helper'


describe Thor::Shell::Color do
  let(:stdout) { double('stdout') }
  let(:stderr) { double('stderr') }

  before do
    Thor::Shell::Basic.any_instance.stub(:stdout).and_return(stdout)
    Thor::Shell::Basic.any_instance.stub(:stderr).and_return(stderr)
  end

  context '#mute!' do
    it 'sets @mute to true' do
      subject.mute!
      expect(subject.instance_variable_get(:@mute)).to be_true
    end
  end

  context '#unmute!' do
    it 'sets @mute to false' do
      subject.unmute!
      expect(subject.instance_variable_get(:@mute)).to be_false
    end
  end

  context '#say' do
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

  context '#say_status' do
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

  context '#warn' do
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
        stdout.should_receive(:puts).with("\e[33mwarning\e[0m")
        stdout.should_receive(:flush).with(no_args())
        subject.warn 'warning'
      end
    end
  end

  context '#deprecated' do
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
