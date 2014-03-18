require 'spec_helper'

describe Berkshelf::GitLocation do
  let(:constraint) { double('comp-vconstraint', satisfies?: true) }
  let(:dependency) do
    double('dep',
      name: "berkshelf-cookbook-fixture",
      version_constraint: constraint,
      locked_version: nil,
    )
  end

  describe "ClassMethods" do
    describe "::new" do
      it 'raises InvalidGitURI if given an invalid Git URI for options[:git]' do
        expect {
          described_class.new(dependency, git: '/something/on/disk')
        }.to raise_error(Berkshelf::InvalidGitURI)
      end
    end
  end

  let(:storage_path) { Berkshelf::CookbookStore.instance.storage_path }
  subject { described_class.new(dependency, git: 'git://github.com/RiotGames/berkshelf-cookbook-fixture.git') }

  describe '#download' do
    context 'when a local revision is present' do
      let(:cached) { double('cached') }

      before do
        Berkshelf::Git.stub(:rev_parse).and_return('abcd1234')
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
      revision = subject.revision

      expect(storage_path).to have_structure {
        directory "#{cached_cookbook.cookbook_name}-#{revision}" do
          file 'metadata.rb'
        end
      }
    end

    context 'given no ref/branch/tag options is given' do
      subject { described_class.new(dependency, git: 'git://github.com/RiotGames/berkshelf-cookbook-fixture.git') }

      it 'sets the ref attribute to the HEAD revision of the cloned repo' do
        subject.download
        expect(subject.ref).to_not be_nil
      end
    end

    context 'given a git repo that does not exist' do
      before { dependency.stub(name: "doesnot_exist") }
      subject { described_class.new(dependency, git: 'git://github.com/RiotGames/thisrepo_does_not_exist.git') }

      it 'raises a GitError' do
        Berkshelf::Git.stub(:git).and_raise(Berkshelf::GitError.new(''))
        expect { subject.download }.to raise_error(Berkshelf::GitError)
      end
    end

    context 'given a git repo that does not contain a cookbook' do
      let(:fake_remote) { remote_path('not_a_cookbook') }
      before { dependency.stub(name: "doesnot_exist") }
      subject { described_class.new(dependency, git: "file://#{fake_remote}.git") }

      it 'raises a CookbookNotFound error' do
        Berkshelf::Git.stub(:clone).and_return {
          FileUtils.mkdir_p(fake_remote)
          Dir.chdir(fake_remote) { |dir| `git init && echo hi > README && git add README && git commit README -m 'README'`; dir }
        }

        expect { subject.download }.to raise_error(Berkshelf::CookbookNotFound)
      end
    end

    context 'given the content at the Git repo does not satisfy the version constraint' do
      before { constraint.stub(satisfies?: false) }
      subject { described_class.new(dependency, git: 'git://github.com/RiotGames/berkshelf-cookbook-fixture.git') }

      it 'raises a CookbookValidationFailure error' do
        expect { subject.download }.to raise_error(Berkshelf::CookbookValidationFailure)
      end
    end

    context 'given a value for tag' do
      let(:tag) { 'v1.0.0' }

      subject do
        described_class.new(dependency, git: 'git://github.com/RiotGames/berkshelf-cookbook-fixture.git', tag: tag)
      end

      let(:cached) { subject.download }
      let(:sha) { subject.revision }
      let(:expected_path) { storage_path.join("#{cached.cookbook_name}-#{sha}") }

      it 'returns a cached cookbook with a path that contains the revision' do
        expect(cached.path).to eq(expected_path)
      end
    end

    context 'give a value for branch' do
      let(:branch) { 'master' }

      subject do
        described_class.new(dependency, git: 'git://github.com/RiotGames/berkshelf-cookbook-fixture.git',
          branch: branch)
      end
      let(:cached) { subject.download }
      let(:sha) { subject.revision }
      let(:expected_path) { storage_path.join("#{cached.cookbook_name}-#{sha}") }

      it 'returns a cached cookbook with a path that contains the revision' do
        expect(cached.path).to eq(expected_path)
      end
    end
  end
end
