require "spec_helper"

describe FileUtils do
  describe "#mv" do
    let(:src) { "src" }
    let(:dest) { "dest" }
    let(:options) { {} }

    it "uses mv by default" do
      expect(FileUtils).to receive(:old_mv).with(src, dest, options)
      FileUtils.mv(src, dest, options)
    end

    it "replaces mv with cp_r and rm_rf" do
      expect(FileUtils).to receive(:cp_r).with(src, dest, options)
      expect(FileUtils).to receive(:rm_rf).with(src)

      FileUtils.mv(src, dest, options)
    end
  end
end
