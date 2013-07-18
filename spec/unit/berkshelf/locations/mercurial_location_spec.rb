require 'spec_helper'

describe Berkshelf::MercurialLocation do

  include Berkshelf::RSpec::Mercurial

  let(:cookbook_uri) { mercurial_origin_for('fake_cookbook', is_cookbook: true, tags: ["1.0.0"], branches: ["mybranch"]) }
  let(:constraint) { double('comp-vconstraint', satisfies?: true) }
  let(:dependency) { double('dep', name: "berkshelf-cookbook-fixture", version_constraint: constraint) }
  let(:storage_path) { Berkshelf::CookbookStore.instance.storage_path }

  describe '.initialize' do
    it 'raises InvalidHgURI if given an invalid URI for options[:hg]' do
      expect {
        described_class.new(dependency, hg: '/something/on/disk')
      }.to raise_error(Berkshelf::InvalidHgURI)
    end
  end

  describe '.tmpdir' do
    it 'creates a temporary directory within the Berkshelf temporary directory' do
      expect(described_class.tmpdir).to include(Berkshelf.tmp_dir)
    end
  end

  subject { described_class.new(dependency, hg: cookbook_uri) }

  describe '#download' do

    before() do
      # recreate the fake repo
      clean_tmp_path
      FileUtils.mkdir_p(storage_path)
      cookbook_uri
    end

    context 'when a local revision is present' do
      let(:cached) { double('cached') }

      before do
        Berkshelf::Mercurial.stub(:rev_parse).and_return('abcd1234')
        described_class.any_instance.stub(:cached?).and_return(true)
        described_class.any_instance.stub(:validate_cached).with(cached).and_return(cached)
        Berkshelf::CachedCookbook.stub(:from_store_path).with(any_args()).and_return(cached)
      end

      it 'returns the cached cookbook' do
        expect(subject.download).to eq(cached)
      end
    end

    it 'returns an instance of Berkshelf::CachedCookbook' do
      expect(subject.download).to be_a(Berkshelf::CachedCookbook)
    end

    it 'downloads the cookbook to the given destination' do
      cached_cookbook = subject.download
      rev = subject.rev

      expect(storage_path).to have_structure {
        directory "#{cached_cookbook.cookbook_name}-#{rev}" do
          file 'metadata.rb'
        end
      }
    end

    context 'given no ref/branch/tag options is given' do
      subject { described_class.new(dependency, hg: cookbook_uri) }

      it 'sets the branch attribute to the default revision of the cloned repo' do
        subject.download
        expect(subject.branch).to_not be_nil
      end
    end

    context 'given a repo that does not exist' do
      before { dependency.stub(name: "doesnot_exist") }
      subject { described_class.new(dependency, hg: 'http://thisdoesntexist.org/notarepo') }

      it 'raises a MercurailError' do
        Berkshelf::Mercurial.stub(:hg).and_raise(Berkshelf::MercurialError.new(''))
        expect {
          subject.download
        }.to raise_error(Berkshelf::MercurialError)
      end
    end

    context 'given a hg repo that does not contain a cookbook' do
      let(:fake_remote) { mercurial_origin_for('not_a_cookbook', is_cookbook: false) }
      subject { described_class.new(dependency, hg: fake_remote) }

      it 'raises a CookbookNotFound error' do
        expect {
          subject.download
        }.to raise_error(Berkshelf::CookbookNotFound)
      end
    end

    context 'given the content at the repo does not satisfy the version constraint' do
      before { constraint.stub(satisfies?: false) }
      subject do
        described_class.new(dependency,
                                   hg: cookbook_uri
        )
      end

      it 'raises a CookbookValidationFailure error' do
        expect {
          subject.download
        }.to raise_error(Berkshelf::CookbookValidationFailure)
      end
    end

    context 'given a value for tag' do
      let(:tag) { '1.0.0' }

      subject do
        described_class.new(dependency,
                                   hg: cookbook_uri,
                                   tag: tag
        )
      end
      let(:cached) { subject.download }
      let(:sha) { subject.rev }
      let(:expected_path) { storage_path.join("#{cached.cookbook_name}-#{sha}") }

      it 'returns a cached cookbook with a path that contains the ref' do
        expect(cached.path).to eq(expected_path)
      end
    end

    context 'give a value for branch' do
      let(:branch) { 'mybranch' }

      subject do
        described_class.new(dependency,
                                   hg: cookbook_uri,
                                   branch: branch
        )
      end
      let(:cached) { subject.download }
      let(:sha) { subject.rev }
      let(:expected_path) { storage_path.join("#{cached.cookbook_name}-#{sha}") }

      it 'returns a cached cookbook with a path that contains the ref' do
        expect(cached.path).to eq(expected_path)
      end
    end
  end
end
