require 'spec_helper'

module Berkshelf
  describe Location do
    let(:dependency) { double(name: 'bacon') }

    describe '.init' do
      it 'finds a :path location by key' do
        instance = described_class.init(dependency, path: '~/Dev/meats/bacon')
        expect(instance).to be_a(PathLocation)
      end

      it 'finds a :git location by key' do
        instance = described_class.init(dependency, git: 'git://foo.com/meats/bacon.git')
        expect(instance).to be_a(GitLocation)
      end

      it 'finds a :github location by key' do
        instance = described_class.init(dependency, github: 'meats/bacon')
        expect(instance).to be_a(GitLocation)
      end

      it 'returns nil when a location cannot be found' do
        instance = described_class.init(dependency, lamesauce: 'meats/bacon')
        expect(instance).to be_nil
      end
    end
  end
end
