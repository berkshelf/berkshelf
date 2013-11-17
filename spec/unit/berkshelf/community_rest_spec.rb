require 'spec_helper'

describe Berkshelf::CommunityREST do
  let(:api_uri) { Berkshelf::CommunityREST::V1_API }
  subject { Berkshelf::CommunityREST.new }

  describe '#download' do
    let(:archive) { double('archive', status: 200, body: nil) }
    let(:extractor) { double('extractor', unpack!: '/destination/path' ) }

    before do
      Berkshelf::Extractor.stub(:new).and_return(extractor)
      subject.stub(:stream).and_return(archive)
    end

    it 'unpacks the archive' do
      subject.stub(:find).and_return('file' => 'http://remote/file')
      subject.stub(:get).with('http://remote/file').and_return(archive)
      expect(extractor).to receive(:unpack!)

      subject.download('bacon', '1.0.0')
    end
  end

  describe '#find' do
    it 'returns the cookbook and version information' do
      subject.stub(:get).with('cookbooks/bacon/versions/1_0_0').and_return(
        double('repsonse', status: 200, parsed: {
          'cookbook' => '/path/to/cookbook',
          'version' => '1.0.0',
        })
      )

      result = subject.find('bacon', '1.0.0')

      expect(result['cookbook']).to eq('/path/to/cookbook')
      expect(result['version']).to eq('1.0.0')
    end

    it 'raises a CookbookNotFound error on a 404 response for a non-existent cookbook' do
      subject.stub(:get).with('cookbooks/not_real/versions/1_0_0').and_return(
        double('response', status: 404)
      )

      expect {
        subject.find('not_real', '1.0.0')
      }.to raise_error(Berkshelf::CookbookNotFound)
    end

    it 'raises a CommunitySiteError error on any non 200 or 404 response' do
      subject.stub(:get).with('cookbooks/not_real/versions/1_0_0').and_return(
        double('response', status: 500)
      )

      expect {
        subject.find('not_real', '1.0.0')
      }.to raise_error(Berkshelf::CommunitySiteError)
    end
  end

  describe '#latest_version' do
    it 'returns the version number of the latest version of the cookbook' do
      subject.stub(:get).with('cookbooks/bacon').and_return(
        double('response', status: 200, parsed: {
          'latest_version' => '1.0.0',
        })
      )

      latest = subject.latest_version('bacon')
      expect(latest).to eq('1.0.0')
    end

    it 'raises a CookbookNotFound error on a 404 response' do
      subject.stub(:get).with('cookbooks/not_real').and_return(
        double('response', status: 404)
      )

      expect {
        subject.latest_version('not_real')
      }.to raise_error(Berkshelf::CookbookNotFound)
    end

    it 'raises a CommunitySiteError error on any non 200 or 404 response' do
      subject.stub(:get).with('cookbooks/not_real').and_return(
        double('response', status: 500)
      )

      expect {
        subject.latest_version('not_real')
      }.to raise_error(Berkshelf::CommunitySiteError)
    end
  end

  describe '#versions' do
    it 'returns an array containing an item for each version' do
      subject.stub(:get).with('cookbooks/bacon').and_return(
        double('response', status: 200, parsed: {
          'versions' => [
            '/bacon/versions/1_0_0',
            '/bacon/versions/2_0_0',
          ]
        })
      )

      versions = subject.versions('bacon')
      expect(versions.size).to eq(2)
    end

    it 'raises a CookbookNotFound error on a 404 response' do
      subject.stub(:get).with('cookbooks/not_real').and_return(
        double('response', status: 404)
      )

      expect {
        subject.versions('not_real')
      }.to raise_error(Berkshelf::CookbookNotFound)
    end

    it 'raises a CommunitySiteError error on any non 200 or 404 response' do
      subject.stub(:get).with('cookbooks/not_real').and_return(
        double('response', status: 500)
      )

      expect {
        subject.versions('not_real')
      }.to raise_error(Berkshelf::CommunitySiteError)
    end
  end

  describe '#uri_escape_version' do
    before { described_class.send(:public, :uri_escape_version) }

    it 'returns a string' do
      expect(subject.uri_escape_version(nil)).to be_a(String)
    end

    it 'converts a version to it\'s underscored version' do
      expect(subject.uri_escape_version('1.1.2')).to eq('1_1_2')
    end

    it 'works when the version has more than three points' do
      expect(subject.uri_escape_version('1.1.1.2')).to eq('1_1_1_2')
    end

    it 'works when the version has less than three points' do
      expect(subject.uri_escape_version('1.2')).to eq('1_2')
    end
  end

  describe '#version_from_uri' do
    before { described_class.send(:public, :version_from_uri) }

    it 'returns a string' do
      expect(subject.version_from_uri(nil)).to be_a(String)
    end

    it 'extracts the version from the URL' do
      expect(subject.version_from_uri('/api/v1/cookbooks/nginx/versions/1_1_2')).to eq('1.1.2')
    end

    it 'works when the version has more than three points' do
      expect(subject.version_from_uri('/api/v1/cookbooks/nginx/versions/1_1_1_2')).to eq('1.1.1.2')
    end

    it 'works when the version has less than three points' do
      expect(subject.version_from_uri('/api/v1/cookbooks/nginx/versions/1_2')).to eq('1.2')
    end
  end
end
