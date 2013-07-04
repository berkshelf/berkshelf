require 'spec_helper'

describe Berkshelf::MercurialLocation, mercurial: true do
  let(:complacent_constraint) { double('comp-vconstraint', satisfies?: true) }

  describe '.initialize' do
    it 'raises InvalidHgURI if given an invalid URI for options[:hg]' do
      expect {
        Berkshelf::MercurialLocation.new('berkshelf-cookbook-fixture', complacent_constraint, hg: '/something/on/disk')
      }.to raise_error(Berkshelf::InvalidHgURI)
    end
  end

  describe '.tmpdir' do
    it 'creates a temporary directory within the Berkshelf temporary directory' do
      expect(Berkshelf::MercurialLocation.tmpdir).to include(Berkshelf.tmp_dir)
    end
  end

  clean_tmp_path
  cookbook_uri = mercurial_origin_for('fake_cookbook', is_cookbook: true)
  subject { Berkshelf::MercurialLocation.new('berkshelf-cookbook-fixture', complacent_constraint, hg: cookbook_uri) }

  describe '#download' do

    before() do
      # recreate the fake repo
      clean_tmp_path
      mercurial_origin_for('fake_cookbook', is_cookbook: true, tags: ["1.0.0"], branches: ["mybranch"])
    end

    context 'when a local revision is present' do
      let(:cached) { double('cached') }

      before do
        Berkshelf::Mercurial.stub(:rev_parse).and_return('abcd1234')
        Berkshelf::MercurialLocation.any_instance.stub(:cached?).and_return(true)
        Berkshelf::MercurialLocation.any_instance.stub(:validate_cached).with(cached).and_return(cached)
        Berkshelf::CachedCookbook.stub(:from_store_path).with(any_args()).and_return(cached)
      end

      it 'returns the cached cookbook' do
        expect(subject.download(tmp_path)).to eq(cached)
      end
    end

    it 'returns an instance of Berkshelf::CachedCookbook' do
      expect(subject.download(tmp_path)).to be_a(Berkshelf::CachedCookbook)
    end

    it 'downloads the cookbook to the given destination' do
      cached_cookbook = subject.download(tmp_path)
      rev = subject.rev

      expect(tmp_path).to have_structure {
        directory "#{cached_cookbook.cookbook_name}-#{rev}" do
          file 'metadata.rb'
        end
      }
    end

    context 'given no ref/branch/tag options is given' do
      subject { Berkshelf::MercurialLocation.new('berkshelf-cookbook-fixture', complacent_constraint, hg: cookbook_uri) }

      it 'sets the branch attribute to the default revision of the cloned repo' do
        subject.download(tmp_path)
        expect(subject.branch).to_not be_nil
      end
    end

    context 'given a repo that does not exist' do
      subject { Berkshelf::MercurialLocation.new('doesnot_exist', complacent_constraint, hg: 'http://thisdoesntexist.org/notarepo') }

      it 'raises a MercurailError' do
        Berkshelf::Mercurial.stub(:hg).and_raise(Berkshelf::MercurialError.new(''))
        expect {
          subject.download(tmp_path)
        }.to raise_error(Berkshelf::MercurialError)
      end
    end

    context 'given a hg repo that does not contain a cookbook' do
      let(:fake_remote) { mercurial_origin_for('not_a_cookbook', is_cookbook: false) }
      subject { Berkshelf::MercurialLocation.new('does_not_exist', complacent_constraint, hg: fake_remote) }

      it 'raises a CookbookNotFound error' do
        expect {
          subject.download(tmp_path)
        }.to raise_error(Berkshelf::CookbookNotFound)
      end
    end

    context 'given the content at the Git repo does not satisfy the version constraint' do
      subject do
        Berkshelf::MercurialLocation.new('berkshelf-cookbook-fixture',
                                   double('constraint', satisfies?: false),
                                   hg: cookbook_uri
        )
      end

      it 'raises a CookbookValidationFailure error' do
        expect {
          subject.download(tmp_path)
        }.to raise_error(Berkshelf::CookbookValidationFailure)
      end
    end

    context 'given a value for tag' do
      let(:tag) { '1.0.0' }

      subject do
        Berkshelf::MercurialLocation.new('berkshelf-cookbook-fixture',
                                   complacent_constraint,
                                   hg: cookbook_uri,
                                   tag: tag
        )
      end
      let(:cached) { subject.download(tmp_path) }
      let(:sha) { subject.rev }
      let(:expected_path) { tmp_path.join("#{cached.cookbook_name}-#{sha}") }

      it 'returns a cached cookbook with a path that contains the ref' do
        expect(cached.path).to eq(expected_path)
      end
    end

    context 'give a value for branch' do
      let(:branch) { 'mybranch' }

      subject do
        Berkshelf::MercurialLocation.new('berkshelf-cookbook-fixture',
                                   complacent_constraint,
                                   hg: cookbook_uri,
                                   branch: branch
        )
      end
      let(:cached) { subject.download(tmp_path) }
      let(:sha) { subject.rev }
      let(:expected_path) { tmp_path.join("#{cached.cookbook_name}-#{sha}") }

      it 'returns a cached cookbook with a path that contains the ref' do
        expect(cached.path).to eq(expected_path)
      end
    end
  end
end
