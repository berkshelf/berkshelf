require 'spec_helper'

describe FileUtils do
  describe '#mv' do
    let(:src) { double('src') }
    let(:dest) { double('dest') }
    let(:options) { double('options') }

    it 'replaces mv with cp_r and rm_rf' do
      subject.stub(:windows?) { true }
      FileUtils.should_receive(:cp_r).with(src, dest, options)
      FileUtils.should_receive(:rm_rf).with(src)

      FileUtils.mv(src, dest, options)
    end
  end
end
