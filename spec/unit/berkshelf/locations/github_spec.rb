require 'spec_helper'

module Berkshelf
  describe GithubLocation do
    let(:dependency) { double(name: 'bacon') }

    describe '.initialize' do
      it 'sets the github uri' do
        instance = described_class.new(dependency, github: 'berkshelf/berkshelf')
        expect(instance.uri).to eq('git://github.com/berkshelf/berkshelf.git')
      end

      it 'uses SSH schema when protocol is passed' do
        instance = described_class.new(dependency, github: 'berkshelf/berkshelf',
          protocol: :ssh)
        expect(instance.uri).to eq('git@github.com:berkshelf/berkshelf.git')
      end
    end 
  end
end
