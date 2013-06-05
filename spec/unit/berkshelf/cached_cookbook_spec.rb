require 'spec_helper'

describe Berkshelf::CachedCookbook do
  let(:path) { fixtures_path.join('cookbooks', 'example_cookbook-0.5.0') }
  let(:cached) { Berkshelf::CachedCookbook.from_path(path) }
  let(:dependencies) { { 'mysql' => '= 1.2.0', 'ntp' => '>= 0.0.0' } }
  let(:recommendations) { { 'database' => '>= 0.0.0' } }

  describe '.from_store_path' do
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
        expect(described_class.from_store_path(tmp_path)).to be_nil
      end
    end

    context 'given a path that does not match the CachedCookbook dirname format' do
      it 'returns nil' do
        path = fixtures_path.join('cookbooks', 'example_cookbook')
        expect(described_class.from_store_path(path)).to be_nil
      end
    end
  end

  describe '::checksum' do
    it 'returns a checksum of the given filepath' do
      path = fixtures_path.join('cookbooks', 'example_cookbook-0.5.0', 'README.md')
      expect(described_class.checksum(path)).to eq('6e21094b7a920e374e7261f50e9c4eef')
    end

    context 'given path does not exist' do
      it 'raises an Errno::ENOENT error' do
        expect {
          described_class.checksum(fixtures_path.join('notexisting.file'))
        }.to raise_error(Errno::ENOENT)
      end
    end
  end


  subject { cached }

  describe '#dependencies' do
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

    it 'returns a hash' do
      expect(subject.dependencies).to be_a(Hash)
    end
  end

  describe '#pretty_hash' do
    shared_examples 'a pretty_hash cookbook attribute' do |attribute, key|
      it "is not present when the `#{attribute}` attribute is nil" do
        subject.stub(attribute.to_sym).and_return(nil)
        expect(subject.pretty_hash).to_not have_key((key || attribute).to_sym)
      end

      it "is not present when the `#{attribute}` attribute is an empty string" do
        subject.stub(attribute.to_sym).and_return('')
        expect(subject.pretty_hash).to_not have_key((key || attribute).to_sym)
      end

      it "is not present when the `#{attribute}` attribute is an empty array" do
        subject.stub(attribute.to_sym).and_return([])
        expect(subject.pretty_hash).to_not have_key((key || attribute).to_sym)
      end

      it "is not present when the `#{attribute}` attribute is an empty hash" do
        subject.stub(attribute.to_sym).and_return([])
        expect(subject.pretty_hash).to_not have_key((key || attribute).to_sym)
      end

      it "is present when the `#{attribute}` attribute has a Hash value" do
        subject.stub(attribute.to_sym).and_return(foo: 'bar')
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

  describe '#to_s' do
    it 'includes the name and version' do
      expect(subject.to_s).to eq("#<#{described_class} #{subject.name_and_version}>")
    end
  end

  describe '#inspect' do
    it 'includes the metadata information' do
      expect(subject.inspect).to eq("#<#{described_class} #{subject.name_and_version}, description: #{subject.description}, author: #{subject.maintainer}, email: #{subject.maintainer_email}, license: #{subject.license}, platforms: {}, dependencies: {}>")
    end
  end
end
