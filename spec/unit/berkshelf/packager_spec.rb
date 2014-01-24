require 'spec_helper'

describe Berkshelf::Packager do
  let(:target) { tmp_path.join("cookbooks.tar.gz").to_s }
  subject { described_class.new(target) }

  its(:out_file) { should eql(target) }

  describe "#run" do
    let(:cookbooks) { fixtures_path.join("cookbooks") }

    it "writes a tar to the #out_file" do
      subject.run(cookbooks)
      expect(File.exist?(subject.out_file)).to be_true
    end
  end

  describe "#validate!" do
    let(:out_dir) { File.dirname(target) }

    context "when the out_file's directory is not writable" do
      before { File.stub(:directory?).with(out_dir).and_return(false) }

      it "raises an error" do
        expect { subject.validate! }.to raise_error(Berkshelf::PackageError,
          "Path is not a directory: #{out_dir}")
      end
    end

    context "when the out_file's directory is not a directory" do
      before { File.stub(:writable?).with(out_dir).and_return(false) }

      it "raises an error" do
        expect { subject.validate! }.to raise_error(Berkshelf::PackageError,
          "Directory is not writable: #{out_dir}")
      end
    end
  end
end
