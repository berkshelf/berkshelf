require 'spec_helper'

describe Berkshelf::GitLocation do
  let(:complacent_constraint) { double('comp-vconstraint', satisfies?: true) }

  describe '.initialize' do
    it 'raises InvalidGitURI if given an invalid Git URI for options[:git]' do
      expect {
        Berkshelf::GitLocation.new('berkshelf-cookbook-fixture', complacent_constraint, git: '/something/on/disk')
      }.to raise_error(Berkshelf::InvalidGitURI)
    end
  end

  describe '.tmpdir' do
    it 'creates a temporary directory within the Berkshelf temporary directory' do
      expect(Berkshelf::GitLocation.tmpdir).to include(Berkshelf.tmp_dir)
    end
  end



  subject { Berkshelf::GitLocation.new('berkshelf-cookbook-fixture', complacent_constraint, git: 'git://github.com/RiotGames/berkshelf-cookbook-fixture.git') }

  describe '#download' do
    context 'when a local revision is present' do
      let(:cached) { double('cached') }

      before do
        Berkshelf::Git.stub(:rev_parse).and_return('abcd1234')
        Berkshelf::GitLocation.any_instance.stub(:cached?).and_return(true)
        Berkshelf::GitLocation.any_instance.stub(:validate_cached).with(cached).and_return(cached)
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
      ref = subject.ref

      expect(tmp_path).to have_structure {
        directory "#{cached_cookbook.cookbook_name}-#{ref}" do
          file 'metadata.rb'
        end
      }
    end

    context 'given no ref/branch/tag options is given' do
      subject { Berkshelf::GitLocation.new('berkshelf-cookbook-fixture', complacent_constraint, git: 'git://github.com/RiotGames/berkshelf-cookbook-fixture.git') }

      it 'sets the branch attribute to the HEAD revision of the cloned repo' do
        subject.download(tmp_path)
        expect(subject.branch).to_not be_nil
      end
    end

    context 'given a git repo that does not exist' do
      subject { Berkshelf::GitLocation.new('doesnot_exist', complacent_constraint, git: 'git://github.com/RiotGames/thisrepo_does_not_exist.git') }

      it 'raises a GitError' do
        Berkshelf::Git.stub(:git).and_raise(Berkshelf::GitError.new(''))
        expect {
          subject.download(tmp_path)
        }.to raise_error(Berkshelf::GitError)
      end
    end

    context 'given a git repo that does not contain a cookbook' do
      let(:fake_remote) { local_git_origin_path_for('not_a_cookbook') }
      subject { Berkshelf::GitLocation.new('doesnot_exist', complacent_constraint, git: "file://#{fake_remote}.git") }

      it 'raises a CookbookNotFound error' do
        subject.stub(:clone).and_return {
          FileUtils.mkdir_p(fake_remote)
          Dir.chdir(fake_remote) { |dir| `git init; echo hi > README; git add README; git commit README -m 'README'`; dir }
        }

        expect {
          subject.download(tmp_path)
        }.to raise_error(Berkshelf::CookbookNotFound)
      end
    end

    context 'given the content at the Git repo does not satisfy the version constraint' do
      subject do
        Berkshelf::GitLocation.new('berkshelf-cookbook-fixture',
          double('constraint', satisfies?: false),
          git: 'git://github.com/RiotGames/berkshelf-cookbook-fixture.git'
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
        Berkshelf::GitLocation.new('berkshelf-cookbook-fixture',
          complacent_constraint,
          git: 'git://github.com/RiotGames/berkshelf-cookbook-fixture.git',
          tag: tag
        )
      end
      let(:cached) { subject.download(tmp_path) }
      let(:sha) { subject.ref }
      let(:expected_path) { tmp_path.join("#{cached.cookbook_name}-#{sha}") }

      it 'returns a cached cookbook with a path that contains the ref' do
        expect(cached.path).to eq(expected_path)
      end
    end

    context 'give a value for branch' do
      let(:branch) { 'master' }

      subject do
        Berkshelf::GitLocation.new('berkshelf-cookbook-fixture',
          complacent_constraint,
          git: 'git://github.com/RiotGames/berkshelf-cookbook-fixture.git',
          branch: branch
        )
      end
      let(:cached) { subject.download(tmp_path) }
      let(:sha) { subject.ref }
      let(:expected_path) { tmp_path.join("#{cached.cookbook_name}-#{sha}") }

      it 'returns a cached cookbook with a path that contains the ref' do
        expect(cached.path).to eq(expected_path)
      end
    end
  end
end
