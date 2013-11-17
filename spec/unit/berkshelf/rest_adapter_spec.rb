require 'spec_helper'

describe Berkshelf::RESTAdapter do
  describe '#get' do
    let(:response) { double('response', status: ['200', 'Ok'], read: nil) }

    before do
      subject.stub(:open).and_return(response)
      subject.stub(:expand)
    end

    it 'uses open-uri' do
      expect(subject).to receive(:open)
      subject.get('/foo/bar')
    end

    it 'returns a new response object' do
      response = subject.get('/foo/bar')
      expect(response).to be_a(Berkshelf::RESTAdapter::Response)
    end
  end
end
