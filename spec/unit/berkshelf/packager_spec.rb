require 'spec_helper'

describe Berkshelf::Packager do
  let(:target) { tmp_path.join("cookbooks.tar.gz").to_s }
  subject { described_class.new(target) }

  it 'has the correct out_file' do
    expect(subject.out_file).to eq(target)
  end

  describe "#run" do
    let(:cookbooks) { fixtures_path.join("cookbooks") }

    it "writes a tar to the #out_file" do
      subject.run(cookbooks)
      expect(File.exist?(subject.out_file)).to be(true)
    end
  end

  describe "#validate!" do
    let(:out_dir) { File.dirname(target) }

    context "when the out_file's directory is not writable" do
      before { allow(File).to receive(:directory?).with(out_dir).and_return(false) }

      it "raises an error" do
        expect { subject.validate! }.to raise_error(Berkshelf::PackageError,
          "Path is not a directory: #{out_dir}")
      end
    end

    context "when the out_file's directory is not a directory" do
      before { allow(File).to receive(:writable?).with(out_dir).and_return(false) }

      it "raises an error" do
        expect { subject.validate! }.to raise_error(Berkshelf::PackageError,
          "Directory is not writable: #{out_dir}")
      end
    end
  end
end
