require 'spec_helper'

describe Berkshelf::CommunityREST, vcr: { record: :new_episodes, serialize_with: :json } do
  describe '.unpack' do
    let(:target) { '/foo/bar' }
    let(:destination) { '/destination/bar' }
    let(:file) { double('file') }

    describe 'a tar.gz file' do
      let(:gzip_reader) { double('gzip_reader') }

      before do
        File.stub(:open).with(target, 'rb').and_return(file)
        Zlib::GzipReader.stub(:new).with(file).and_return(gzip_reader)
        Archive::Tar::Minitar.stub(:unpack).with(gzip_reader, destination)
      end

      it 'unpacks the file' do
        File.should_receive(:open).with(target, 'rb')
        ::IO.should_receive(:binread).with(target, 2).and_return([0x1F, 0x8B].pack("C*"))
        Zlib::GzipReader.should_receive(:new).with(file)
        Archive::Tar::Minitar.should_receive(:unpack).with(gzip_reader, destination)

        expect(Berkshelf::CommunityREST.unpack(target, destination)).to eq(destination)
      end
    end

    describe 'a tar file' do
      before do
        File.stub(:open).with(target, 'rb').and_return(file)
        Archive::Tar::Minitar.stub(:unpack).with(target, destination)
      end

      it 'unpacks the file' do
        ::IO.should_receive(:binread).once
        ::IO.should_receive(:binread).with(target, 8, 257).and_return("ustar\x0000")
        Archive::Tar::Minitar.should_receive(:unpack).with(target, destination)

        expect(Berkshelf::CommunityREST.unpack(target, destination)).to eq(destination)
      end
    end

    describe 'a tar.bz2 file' do
      let(:bzip2_reader) { double('bzip2_reader') }

      before do
        File.stub(:open).with(target, 'rb').and_return(file)
        RBzip2::Decompressor.stub(:new).with(file).and_return(bzip2_reader)
        Archive::Tar::Minitar.stub(:unpack).with(bzip2_reader, destination)
      end

      it 'unpacks the file' do
        File.should_receive(:open).with(target, 'rb')
        ::IO.should_receive(:binread).twice
        ::IO.should_receive(:binread).with(target, 3).and_return('BZh')
        RBzip2::Decompressor.should_receive(:new).with(file)
        Archive::Tar::Minitar.should_receive(:unpack).with(bzip2_reader, destination)

        expect(Berkshelf::CommunityREST.unpack(target, destination)).to eq(destination)
      end
    end
  end

  describe '.uri_escape_version' do
    it 'returns a string' do
      expect(Berkshelf::CommunityREST.uri_escape_version(nil)).to be_a(String)
    end

    it 'converts a version to it\'s underscored version' do
      expect(Berkshelf::CommunityREST.uri_escape_version('1.1.2')).to eq('1_1_2')
    end

    it 'works when the version has more than three points' do
      expect(Berkshelf::CommunityREST.uri_escape_version('1.1.1.2')).to eq('1_1_1_2')
    end

    it 'works when the version has less than three points' do
      expect(Berkshelf::CommunityREST.uri_escape_version('1.2')).to eq('1_2')
    end
  end

  describe '.version_from_uri' do
    it 'returns a string' do
      expect(Berkshelf::CommunityREST.version_from_uri(nil)).to be_a(String)
    end

    it 'extracts the version from the URL' do
      expect(Berkshelf::CommunityREST.version_from_uri('/api/v1/cookbooks/nginx/versions/1_1_2')).to eq('1.1.2')
    end

    it 'works when the version has more than three points' do
      expect(Berkshelf::CommunityREST.version_from_uri('/api/v1/cookbooks/nginx/versions/1_1_1_2')).to eq('1.1.1.2')
    end

    it 'works when the version has less than three points' do
      expect(Berkshelf::CommunityREST.version_from_uri('/api/v1/cookbooks/nginx/versions/1_2')).to eq('1.2')
    end
  end



  let(:api_uri) { Berkshelf::CommunityREST::V1_API }

  subject do
    Berkshelf::CommunityREST.new(api_uri)
  end

  describe '#download' do
    let(:archive) { double('archive', path: '/foo/bar', unlink: true) }

    before do
      subject.stub(:stream).with(any_args()).and_return(archive)
      Berkshelf::CommunityREST.stub(:unpack)
    end

    it 'unpacks the archive' do
      Berkshelf::CommunityREST.should_receive(:unpack).with('/foo/bar').once
      archive.should_receive(:unlink).once

      subject.download('nginx', '1.4.0')
    end
  end

  describe '#find' do
    it 'returns the cookbook and version information' do
      result = subject.find('nginx', '1.4.0')

      expect(result.cookbook).to eq('http://cookbooks.opscode.com/api/v1/cookbooks/nginx')
      expect(result.version).to eq('1.4.0')
    end

    it 'raises a CookbookNotFound error on a 404 response for a non-existent cookbook' do
      expect {
        subject.find('not_a_real_cookbook_that_anyone_should_ever_make', '0.1.0')
      }.to raise_error(Berkshelf::CookbookNotFound)
    end

    it 'raises a CookbookNotFound error on a 404 response for a non-existent version' do
      expect {
        subject.find('nginx', '0.0.0')
      }.to raise_error(Berkshelf::CookbookNotFound)
    end

    # @warn if you re-record the VCR cassettes, you'll need to manually change the
    # HTTP Response Code in the YAML file to 500
    it 'raises a CommunitySiteError error on any non 200 or 404 response' do
      expect {
        subject.find('not_a_real_cookbook_that_anyone_should_ever_make', '0.0.0')
      }.to raise_error(Berkshelf::CommunitySiteError)
    end
  end

  describe '#latest_version' do
    it 'returns the version number of the latest version of the cookbook' do
      expect(subject.latest_version('nginx')).to eq('1.4.0')
    end

    it 'raises a CookbookNotFound error on a 404 response' do
      expect {
        subject.latest_version('not_a_real_cookbook_that_anyone_should_ever_make')
      }.to raise_error(Berkshelf::CookbookNotFound)
    end

    # @warn if you re-record the VCR cassettes, you'll need to manually change the
    # HTTP Response Code in the YAML file to 500
    it 'raises a CommunitySiteError error on any non 200 or 404 response' do
      expect {
        subject.latest_version('not_a_real_cookbook_that_anyone_should_ever_make')
      }.to raise_error(Berkshelf::CommunitySiteError)
    end
  end

  describe '#versions' do
    it 'returns an array containing an item for each version' do
      expect(subject.versions('nginx')).to have(24).versions
    end

    it 'raises a CookbookNotFound error on a 404 response' do
      expect {
        subject.versions('not_a_real_cookbook_that_anyone_should_ever_make')
      }.to raise_error(Berkshelf::CookbookNotFound)
    end

    # @warn if you re-record the VCR cassettes, you'll need to manually change the
    # HTTP Response Code in the YAML file to 500
    it 'raises a CommunitySiteError error on any non 200 or 404 response' do
      expect {
        subject.versions('not_a_real_cookbook_that_anyone_should_ever_make')
      }.to raise_error(Berkshelf::CommunitySiteError)
    end
  end

  describe '#satisfy' do
    it 'returns the version number of the best solution' do
      expect(subject.satisfy('nginx', '= 1.1.0')).to eq('1.1.0')
    end
  end

  describe '#stream' do
    pending
  end
end
