require 'spec_helper'

describe Berkshelf::Extractor do
  describe '.initialize' do
    context 'when the parameter is a File' do
      let(:file) { Tempfile.new('extractor-test') }

      it 'uses the File path' do
        instance = described_class.new(file)
        expect(instance.package).to be_a(String)
      end

      it 'closes the file' do
        instance = described_class.new(file)
        expect(file).to be_closed
      end
    end

    context 'when the parameter is a String' do
      let(:path) { '/var/path' }

      it 'sets the path' do
        instance = described_class.new(path)
        expect(instance.package).to eq(path)
      end
    end
  end

  let(:path) { '/var/path' }
  subject { described_class.new(path) }

  describe '#unpack!' do
    before do
      subject.stub(:gzip_file?)
      subject.stub(:tar_file?)

      subject.stub(:unpack_from_gzip)
      subject.stub(:unpack_from_tar)
    end

    context 'when the file is a gzip' do
      it 'unpacks as a gzip' do
        subject.stub(:gzip_file?).and_return(true)
        expect(subject).to receive(:unpack_from_gzip)
        subject.unpack!
      end
    end

    context 'when the file is a tar' do
      it 'unpacks as a tar' do
        subject.stub(:tar_file?).and_return(true)
        expect(subject).to receive(:unpack_from_tar)
        subject.unpack!
      end
    end

    context 'when the file is an unknown type' do
      it 'raises an error' do
        expect { subject.unpack! }.to raise_error(Berkshelf::UnknownCompressionType)
      end
    end
  end

  describe '#unpack' do
    before { subject.stub(:unpack!) }

    it 'calls #unpack!' do
      expect(subject).to receive(:unpack!)
      subject.unpack
    end

    it 'returns false if an error is raised' do
      subject.stub(:unpack!).and_raise
      expect(subject.unpack).to be_false
    end
  end
end
