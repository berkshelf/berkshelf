require 'spec_helper'

describe Berkshelf::CachedCookbook do
  describe '.from_store_path' do
    let(:path) { fixtures_path.join('cookbooks', 'example_cookbook-0.5.0') }
    let(:cached) { Berkshelf::CachedCookbook.from_path(path) }

    it 'returns a CachedCookbook' do
      expect(cached).to be_a(Berkshelf::CachedCookbook)
    end

    it 'sets a version number' do
      expect(cached.version).to eq('0.5.0')
    end

    it 'sets the metadata.name value to the cookbook_name' do
      expect(cached.metadata.name).to eq('example_cookbook')
    end

    context 'given a path that does not contain a cookbook' do
      it 'returns nil' do
        expect(Berkshelf::CachedCookbook.from_store_path(tmp_path)).to be_nil
      end
    end

    context 'given a path that does not match the CachedCookbook dirname format' do
      it 'returns nil' do
        path = fixtures_path.join('cookbooks', 'example_cookbook')
        expect(Berkshelf::CachedCookbook.from_store_path(path)).to be_nil
      end

      context 'given an already cached cookbook' do
        let!(:cached) { described_class.from_store_path(path) }

        it 'returns the cached cookbook instance' do
          expect(described_class.from_store_path(path)).to eq(cached)
        end
      end
    end

    describe '#checksum' do
      it 'returns a checksum of the given filepath' do
        path = fixtures_path.join('cookbooks', 'example_cookbook-0.5.0', 'README.md')
        expect(Berkshelf::CachedCookbook.checksum(path)).to eq('6e21094b7a920e374e7261f50e9c4eef')
      end

      context 'given path does not exist' do
        it 'raises an Errno::ENOENT error' do
          expect {
            Berkshelf::CachedCookbook.checksum(fixtures_path.join('notexisting.file'))
          }.to raise_error(Errno::ENOENT)
        end
      end
    end
  end


  describe '#dependencies' do
    let(:dependencies) { { 'mysql' => '= 1.2.0', 'ntp' => '>= 0.0.0' } }
    let(:recommendations) { { 'database' => '>= 0.0.0' } }

    let(:path) do
      generate_cookbook(Berkshelf.cookbook_store.storage_path, 'sparkle', '0.1.0', dependencies: dependencies, recommendations: recommendations)
    end

    subject { Berkshelf::CachedCookbook.from_store_path(path) }

    it 'contains depends from the cookbook metadata' do
      expect(subject.dependencies).to include(dependencies)
    end

    it 'contains recommendations from the cookbook metadata' do
      expect(subject.dependencies).to include(recommendations)
    end
  end
end
