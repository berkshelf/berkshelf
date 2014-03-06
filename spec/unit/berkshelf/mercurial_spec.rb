require 'spec_helper'

describe Berkshelf::Mercurial, :hg do
  include Berkshelf::RSpec::Mercurial

  let(:hg) { Berkshelf::Mercurial }

  describe '::find_hg' do
    it 'finds hg' do
      expect(described_class.find_hg).to_not be_nil
    end

    it 'raises an error if mercurial cannot be not found' do
      ENV.should_receive(:[]).with('PATH').and_return(String.new)

      expect {
        described_class.find_hg
      }.to raise_error(Berkshelf::MercurialNotFound)
    end
  end

  describe '::clone' do
    let(:target) { clone_path('nginx') }

    it 'clones the repository to the target path' do
      origin_uri = mercurial_origin_for('nginx')

      described_class.clone(origin_uri, target)

      expect(target).to exist
      expect(target).to be_directory
    end
  end

  describe '::checkout' do
    let(:repo_path) { clone_path('nginx') }
    let(:repo) {
      origin_uri = mercurial_origin_for('nginx', tags: ['1.0.1', '1.0.2'], branches: ['topic', 'next_topic'])
      hg.clone(origin_uri, repo_path)
    }

    shared_examples 'able to checkout hg rev' do |test_rev|
      it 'checks out the specified rev of the given repository' do
        hg.checkout(repo, rev)

        Dir.chdir repo_path do
          test_rev ||= rev
          expect(%x[hg id -r #{test_rev}].split(' ').first).to eq(%x[hg id -i].strip)
        end
      end
    end

    context 'with sha commit id' do
      let(:rev) { id_for_rev('nginx', '1.0.1') }

      it_behaves_like 'able to checkout hg rev'
    end

    context 'with tags' do
      let(:rev) { '1.0.1' }

      it_behaves_like 'able to checkout hg rev'

      context 'after checking out another tag' do
        let(:other_tag) { '1.0.2' }
        before do
          hg.checkout(repo, other_tag)
          Dir.chdir repo_path do
            shell_out "echo 'uncommitted change' >> content_file"
          end
        end

        it_behaves_like 'able to checkout hg rev'
      end
    end

    context 'with branches' do
      let(:rev) { 'topic' }

      it_behaves_like 'able to checkout hg rev', 'topic'

      context 'after checking out another branch' do
        let(:other_branch) { 'next_topic' }
        before do
          hg.checkout(repo, other_branch)
          Dir.chdir repo_path do
            shell_out "echo 'uncommitted change' >> content_file"
          end
        end

        it_behaves_like 'able to checkout hg rev', 'topic'
      end
    end
  end

  describe '::rev_parse' do
    let(:repo_path) { clone_path('nginx') }

    before(:each) do
      origin_uri = mercurial_origin_for('nginx', tags: ['1.1.1'])
      described_class.clone(origin_uri, repo_path)
      described_class.checkout(repo_path, id_for_rev('nginx', '1.1.1'))
    end

    it 'returns the ref for HEAD' do
      rev = described_class.rev_parse(repo_path)
      ref = id_for_rev('nginx', '1.1.1')

      expect(rev).to eql(ref)
    end
  end

  let(:https_uri) { 'https://hghub.com/reset/' }
  let(:http_uri) { 'http://hghub.com/reset/' }
  let(:invalid_uri) { '/something/on/disk' }

  describe '::validate_uri' do
    context 'given an invalid URI' do
      it 'returns false' do
        expect(described_class.validate_uri(invalid_uri)).to be_false
      end
    end

    context 'given a HTTP URI' do
      it 'returns true' do
        expect(described_class.validate_uri(http_uri)).to be_true
      end
    end

    context 'given a valid HTTPS URI' do
      it 'returns true' do
        expect(described_class.validate_uri(https_uri)).to be_true
      end
    end

    context 'given an integer' do
      it 'returns false' do
        expect(described_class.validate_uri(123)).to be_false
      end
    end
  end

  describe '::validate_uri!' do
    context 'given an invalid URI' do
      it 'raises InvalidHgURI' do
        expect {
          described_class.validate_uri!(invalid_uri)
        }.to raise_error(Berkshelf::InvalidHgURI)
      end
    end

    context 'given a HTTP URI' do
      it 'raises InvalidHgURI' do
        expect(described_class.validate_uri!(http_uri)).to be_true
      end
    end

    context 'given a valid HTTPS URI' do
      it 'returns true' do
        expect(described_class.validate_uri!(https_uri)).to be_true
      end
    end

    context 'given an integer' do
      it 'raises InvalidHgURI' do
        expect {
          described_class.validate_uri!(123)
        }.to raise_error(Berkshelf::InvalidHgURI)
      end
    end
  end
end
