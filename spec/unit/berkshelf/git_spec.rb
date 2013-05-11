require 'spec_helper'

describe Berkshelf::Git do
  let(:git) { Berkshelf::Git }

  describe '.find_git' do
    it 'finds git' do
      expect(Berkshelf::Git.find_git).to_not be_nil
    end

    it 'raises an error if git cannot be not found' do
      ENV.should_receive(:[]).with('PATH').and_return(String.new)

      expect {
        Berkshelf::Git.find_git
      }.to raise_error(Berkshelf::GitNotFound)
    end
  end

  describe '.clone' do
    let(:target) { clone_target_for('nginx') }

    it 'clones the repository to the target path' do
      origin_uri = git_origin_for('nginx')
      Berkshelf::Git.clone(origin_uri, target)

      expect(target).to exist
      expect(target).to be_directory
    end
  end

  describe '.checkout' do
    let(:repo_path) { clone_target_for('nginx') }
    let(:repo) {
      origin_uri = git_origin_for('nginx', tags: ['1.0.1', '1.0.2'], branches: ['topic', 'next_topic'])
      git.clone(origin_uri, repo_path)
    }

    shared_examples 'able to checkout git ref' do |test_ref|
      it 'checks out the specified ref of the given repository' do
        git.checkout(repo, ref)

        Dir.chdir repo_path do
          test_ref ||= ref
          expect(%x[git rev-parse #{test_ref}]).to eq(%x[git rev-parse HEAD])
        end
      end
    end

    context 'with sha commit id' do
      let(:ref) { git_sha_for_ref('nginx', '1.0.1') }

      it_behaves_like 'able to checkout git ref'
    end

    context 'with tags' do
      let(:ref) { '1.0.1' }

      it_behaves_like 'able to checkout git ref'

      context 'after checking out another tag' do
        let(:other_tag) { '1.0.2' }
        before do
          git.checkout(repo, other_tag)
          Dir.chdir repo_path do
            run! "echo 'uncommitted change' >> content_file"
          end
        end

        it_behaves_like 'able to checkout git ref'
      end
    end

    context 'with branches' do
      let(:ref) { 'topic' }

      it_behaves_like 'able to checkout git ref', 'origin/topic'

      context 'after checking out another branch' do
        let(:other_branch) { 'next_topic' }
        before do
          git.checkout(repo, other_branch)
          Dir.chdir repo_path do
            run! "echo 'uncommitted change' >> content_file"
          end
        end

        it_behaves_like 'able to checkout git ref', 'origin/topic'
      end
    end
  end

  describe '.rev_parse' do
    let(:repo_path) { clone_target_for('nginx') }
    before(:each) do |example|
      origin_uri = git_origin_for('nginx', tags: ['1.1.1'])
      Berkshelf::Git.clone(origin_uri, repo_path)
      Berkshelf::Git.checkout(repo_path, git_sha_for_ref('nginx', '1.1.1'))
    end

    it 'returns the ref for HEAD' do
      rev = Berkshelf::Git.rev_parse(repo_path)
      ref = git_sha_for_ref('nginx', '1.1.1')

      expect(rev).to eql(ref)
    end
  end

  describe '.show_ref' do
    let(:repo_path) { clone_target_for('nginx') }
    let(:tags) { ['1.0.1'] }
    let(:branches) { ['topic'] }
    let!(:repo) {
      origin_uri = git_origin_for('nginx', tags: tags, branches: branches)
      git.clone(origin_uri, repo_path)
    }

    it 'returns the commit id for the given tag' do
      show = git.show_ref(repo_path, '1.0.1')
      ref = git_sha_for_ref('nginx', '1.0.1')

      expect(show).to eq(ref)
    end

    it 'returns the commit id for the given branch' do
      show = git.show_ref(repo_path, 'topic')
      ref = git_sha_for_ref('nginx', 'topic')
      expect(show).to eq(ref)
    end

    context 'with an ambiguous ref' do
      let(:tags) { ['topic'] }
      let(:branches) { ['topic'] }

      it 'raises an error' do
        expect {
          git.show_ref(repo_path, 'topic')
        }.to raise_error(Berkshelf::AmbiguousGitRef)
      end
    end
  end

  describe '.revision_from_ref' do
    let(:repo_path) { clone_target_for('nginx') }
    let(:tags) { ['1.0.1'] }
    let(:branches) { ['topic'] }
    let!(:repo) {
      origin_uri = git_origin_for('nginx', tags: tags, branches: branches)
      git.clone(origin_uri, repo_path)
    }

    context 'with sha commit id' do
      let(:revision) { git_sha_for_ref('nginx', '1.0.1') }
      it 'returns the passed revision' do
        rev = git.revision_from_ref(repo_path, revision)
        expect(rev).to eq(revision)
      end
    end

    context 'with tag' do
      let(:revision) { git_sha_for_ref('nginx', '1.0.1') }
      it 'returns the revision' do
        rev = git.revision_from_ref(repo_path, '1.0.1')
        expect(rev).to eq(revision)
      end
    end

    context 'with branch' do
      let(:revision) { git_sha_for_ref('nginx', 'topic') }
      it 'returns the revision' do
        rev = git.revision_from_ref(repo_path, 'topic')
        expect(rev).to eq(revision)
      end
    end

    context 'with an invalid ref' do
      let(:ref) { 'foobar' }
      it 'raises an error' do
        expect {
          git.revision_from_ref(repo_path, ref)
        }.to raise_error(Berkshelf::InvalidGitRef)
      end
    end
  end

  let(:readonly_uri) { 'git://github.com/reset/thor-foodcritic.git' }
  let(:https_uri) { 'https://github.com/reset/solve.git' }
  let(:http_uri) { 'http://github.com/reset/solve.git' }
  let(:invalid_uri) { '/something/on/disk' }

  describe '.validate_uri' do
    context 'given a valid Git read-only URI' do
      it 'returns true' do
        expect(Berkshelf::Git.validate_uri(readonly_uri)).to be_true
      end
    end

    context 'given a valid Git HTTPS URI' do
      it 'returns true' do
        expect(Berkshelf::Git.validate_uri(https_uri)).to be_true
      end
    end

    context 'given a valid Github SSH URI' do
      it 'returns true' do
        expect(Berkshelf::Git.validate_uri('git@github.com:reset/solve.git')).to be_true
      end
    end

    context "given a valid SSH URI without an 'organization'" do
      it 'returns true' do
        expect(Berkshelf::Git.validate_uri('gituser@githost:solve.git')).to be_true
      end
    end

    context 'given a valid git+ssh URI without an username' do
      it 'returns true' do
        expect(Berkshelf::Git.validate_uri('git+ssh://host.com/repo')).to be_true
      end
    end

    context 'given a valid git+ssh URI with an username' do
      it 'returns true' do
        expect(Berkshelf::Git.validate_uri('git+ssh://user@host.com/repo')).to be_true
      end
    end

    context 'given a valid URI with a dash in the hostname' do
      it 'returns true' do
        expect(Berkshelf::Git.validate_uri('git://user@git-host.com/repo')).to be_true
      end
    end

    context 'given a valid URI with host being a subdomain' do
      it 'returns true' do
        expect(Berkshelf::Git.validate_uri('git://user@git.host.com/repo')).to be_true
      end
    end

    context 'given a valid git+ssh URI with home directory expansion' do
      it 'returns true' do
        expect(Berkshelf::Git.validate_uri('git+ssh://user@host.com/~repo')).to be_true
      end
    end

    context 'given an invalid URI' do
      it 'returns false' do
        expect(Berkshelf::Git.validate_uri(invalid_uri)).to be_false
      end
    end

    context 'given a HTTP URI' do
      it 'returns true' do
        expect(Berkshelf::Git.validate_uri(http_uri)).to be_true
      end
    end

    context 'given an integer' do
      it 'returns false' do
        expect(Berkshelf::Git.validate_uri(123)).to be_false
      end
    end
  end

  describe '.validate_uri!' do
    context 'given a valid Git read-only URI' do
      it 'returns true' do
        expect(Berkshelf::Git.validate_uri!(readonly_uri)).to be_true
      end
    end

    context 'given a valid Git HTTPS URI' do
      it 'returns true' do
        expect(Berkshelf::Git.validate_uri!(https_uri)).to be_true
      end
    end

    context 'given a valid Git SSH URI' do
      it 'returns true' do
        expect(Berkshelf::Git.validate_uri!('git@github.com:reset/solve.git')).to be_true
      end
    end

    context "given a valid SSH URI without an 'organization'" do
      it 'returns true' do
        expect(Berkshelf::Git.validate_uri('gituser@githost:solve.git')).to be_true
      end
    end

    context 'given an invalid URI' do
      it 'raises InvalidGitURI' do
        expect {
          Berkshelf::Git.validate_uri!(invalid_uri)
        }.to raise_error(Berkshelf::InvalidGitURI)
      end
    end

    context 'given a HTTP URI' do
      it 'raises InvalidGitURI' do
        expect(Berkshelf::Git.validate_uri!(http_uri)).to be_true
      end
    end

    context 'given an integer' do
      it 'raises InvalidGitURI' do
        expect {
          Berkshelf::Git.validate_uri!(123)
        }.to raise_error(Berkshelf::InvalidGitURI)
      end
    end
  end
end
