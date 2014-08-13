require 'spec_helper'

describe Berkshelf::CachedCookbook do
  describe "ClassMethods" do
    describe '::from_store_path' do
      let(:path) { fixtures_path.join('cookbooks', 'example_cookbook-0.5.0') }
      let(:cached) { described_class.from_path(path) }

      it 'returns a CachedCookbook' do
        expect(cached).to be_a(described_class)
      end

      it 'sets a version number' do
        expect(cached.version).to eq('0.5.0')
      end

      it 'sets the metadata.name value to the cookbook_name' do
        expect(cached.metadata.name).to eq('example_cookbook')
      end

      context 'given a path that does not contain a cookbook' do
        it 'returns nil' do
          expect(described_class.from_store_path(tmp_path)).to be_nil
        end
      end

      context 'given a path that does not match the CachedCookbook dirname format' do
        it 'returns nil' do
          path = fixtures_path.join('cookbooks', 'example_cookbook')
          expect(described_class.from_store_path(path)).to be_nil
        end
      end

      context 'given an already cached cookbook' do
        let!(:cached) { described_class.from_store_path(path) }

        it 'returns the cached cookbook instance' do
          expect(described_class.from_store_path(path)).to eq(cached)
        end
      end
    end

    describe '::checksum' do
      it 'returns a checksum of the given filepath' do
        path = fixtures_path.join('cookbooks', 'example_cookbook-0.5.0', 'README.md')
        expected_md5 = if IO.binread(path).include?("\r\n")
                         # On windows, with git configured for auto crlf
                         "2414583f86c9eb68bdbb0be391939341"
                       else
                         "6e21094b7a920e374e7261f50e9c4eef"
                       end
        expect(described_class.checksum(path)).to eq(expected_md5)
      end

      context 'given path does not exist' do
        it 'raises an Errno::ENOENT error' do
          expect {
            described_class.checksum(fixtures_path.join('notexisting.file'))
          }.to raise_error(Errno::ENOENT)
        end
      end
    end
  end

  let(:dependencies) { { 'mysql' => '= 1.2.0', 'ntp' => '>= 0.0.0' } }
  let(:recommendations) { { 'database' => '>= 0.0.0' } }
  let(:path) do
    generate_cookbook(Berkshelf.cookbook_store.storage_path,
      'sparkle', '0.1.0', dependencies: dependencies, recommendations: recommendations)
  end

  subject { Berkshelf::CachedCookbook.from_store_path(path) }

  describe '#dependencies' do
    it 'contains depends from the cookbook metadata' do
      expect(subject.dependencies).to include(dependencies)
    end

    it 'contains recommendations from the cookbook metadata' do
      expect(subject.dependencies).to include(recommendations)
    end

    it 'returns a hash' do
      expect(subject.dependencies).to be_a(Hash)
    end
  end

  describe '#pretty_hash' do
    shared_examples 'a pretty_hash cookbook attribute' do |attribute, key|
      it "is not present when the `#{attribute}` attribute is nil" do
        allow(subject).to receive(attribute.to_sym).and_return(nil)
        expect(subject.pretty_hash).to_not have_key((key || attribute).to_sym)
      end

      it "is not present when the `#{attribute}` attribute is an empty string" do
        allow(subject).to receive(attribute.to_sym).and_return('')
        expect(subject.pretty_hash).to_not have_key((key || attribute).to_sym)
      end

      it "is not present when the `#{attribute}` attribute is an empty array" do
        allow(subject).to receive(attribute.to_sym).and_return([])
        expect(subject.pretty_hash).to_not have_key((key || attribute).to_sym)
      end

      it "is not present when the `#{attribute}` attribute is an empty hash" do
        allow(subject).to receive(attribute.to_sym).and_return([])
        expect(subject.pretty_hash).to_not have_key((key || attribute).to_sym)
      end

      it "is present when the `#{attribute}` attribute has a Hash value" do
        allow(subject).to receive(attribute.to_sym).and_return(foo: 'bar')
        expect(subject.pretty_hash).to have_key((key || attribute).to_sym)
      end
    end

    it_behaves_like 'a pretty_hash cookbook attribute', 'cookbook_name', 'name'
    it_behaves_like 'a pretty_hash cookbook attribute', 'version'
    it_behaves_like 'a pretty_hash cookbook attribute', 'description'
    it_behaves_like 'a pretty_hash cookbook attribute', 'maintainer', 'author'
    it_behaves_like 'a pretty_hash cookbook attribute', 'maintainer_email', 'email'
    it_behaves_like 'a pretty_hash cookbook attribute', 'license'
    it_behaves_like 'a pretty_hash cookbook attribute', 'platforms'
    it_behaves_like 'a pretty_hash cookbook attribute', 'dependencies'
  end
end
