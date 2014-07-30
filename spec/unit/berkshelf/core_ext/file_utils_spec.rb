require 'spec_helper'

describe FileUtils do
  describe '#mv' do
    let(:src) { double('src') }
    let(:dest) { double('dest') }
    let(:options) { double('options') }

    it 'replaces mv with cp_r and rm_rf' do
      allow(subject).to receive(:windows?) { true }
      expect(FileUtils).to receive(:cp_r).with(src, dest, options)
      expect(FileUtils).to receive(:rm_rf).with(src)

      FileUtils.mv(src, dest, options)
    end
  end
end
