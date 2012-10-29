require 'spec_helper'

describe FileUtils do
  describe "#mv" do
    let(:src) { double('src') }
    let(:dest) { double('dest') }
    let(:options) { double('options') }

    it "delegates to #safe_mv if on Windows" do
      subject.stub(:windows?) { true }
      FileUtils.should_receive(:safe_mv).with(src, dest, options)

      FileUtils.mv(src, dest, options)
    end

    it "delegates to #old_mv if not on Windows" do
      subject.stub(:windows?) { false }
      FileUtils.should_receive(:old_mv).with(src, dest, options)

      FileUtils.mv(src, dest, options)
    end
  end
end
