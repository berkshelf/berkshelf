require 'spec_helper'

module Berkshelf
  describe GitLocation do
    let(:dependency) { double(name: 'bacon') }

    subject do
      described_class.new(dependency, git: 'https://repo.com', branch: 'ham',
        tag: 'v1.2.3', ref: 'abc123', revision: 'defjkl123456', rel: 'hi')
    end

    describe '.initialize' do
      it 'sets the uri' do
        instance = described_class.new(dependency, git: 'https://repo.com')
        expect(instance.uri).to eq('https://repo.com')
      end

      it 'sets the branch' do
        instance = described_class.new(dependency,
          git: 'https://repo.com', branch: 'magic_new_feature')
        expect(instance.branch).to eq('magic_new_feature')
      end

      it 'sets the tag' do
        instance = described_class.new(dependency,
          git: 'https://repo.com', tag: 'v1.2.3')
        expect(instance.tag).to eq('v1.2.3')
      end

      it 'adds the ref' do
        instance = described_class.new(dependency,
          git: 'https://repo.com', ref: 'abc123')
        expect(instance.ref).to eq('abc123')
      end

      it 'sets the revision' do
        instance = described_class.new(dependency,
          git: 'https://repo.com', revision: 'abcde12345')
        expect(instance.revision).to eq('abcde12345')
      end

      it 'sets the rel' do
        instance = described_class.new(dependency,
          git: 'https://repo.com', rel: 'internal/path')
        expect(instance.rel).to eq('internal/path')
      end

      context 'rev_parse' do
        def rev_parse(instance)
          instance.instance_variable_get(:@rev_parse)
        end

        it 'uses the :ref option with priority' do
          instance = described_class.new(dependency,
            git: 'https://repo.com', ref: 'abc123', branch: 'magic_new_feature')
          expect(rev_parse(instance)).to eq('abc123')
        end

        it 'uses the :branch option with priority' do
          instance = described_class.new(dependency,
            git: 'https://repo.com', branch: 'magic_new_feature', tag: 'v1.2.3')
          expect(rev_parse(instance)).to eq('magic_new_feature')
        end

        it 'uses the :tag option' do
          instance = described_class.new(dependency,
            git: 'https://repo.com', tag: 'v1.2.3')
          expect(rev_parse(instance)).to eq('v1.2.3')
        end

        it 'uses "master" when none is given' do
          instance = described_class.new(dependency, git: 'https://repo.com')
          expect(rev_parse(instance)).to eq('master')
        end
      end
    end

    describe '#installed?' do
      it 'returns false when there is no revision' do
        subject.stub(:revision).and_return(nil)
        expect(subject.installed?).to be_false
      end

      it 'returns false when the install_path does not exist' do
        subject.stub(:revision).and_return('abcd1234')
        subject.stub(:install_path).and_return(double(exist?: false))
        expect(subject.installed?).to be_false
      end

      it 'returns true when the location is installed' do
        subject.stub(:revision).and_return('abcd1234')
        subject.stub(:install_path).and_return(double(exist?: true))
        expect(subject.installed?).to be_true
      end
    end

    describe '#install' do
      before do
        File.stub(:chmod)
        FileUtils.stub(:cp_r)
        subject.stub(:validate_cached!)
        subject.stub(:git)
      end

      context 'when the repository is cached' do
        it 'pulls a new version' do
          Dir.stub(:chdir) { |args, &b| b.call } # Force eval the chdir block

          subject.stub(:cached?).and_return(true)
          expect(subject).to receive(:git).with(
            'fetch --force --tags https://repo.com "refs/heads/*:refs/heads/*"'
          )
          subject.install
        end
      end

      context 'when the revision is not cached' do
        it 'clones the repository' do
          Dir.stub(:chdir) { |args, &b| b.call } # Force eval the chdir block

          cache_path = subject.send(:cache_path)
          subject.stub(:cached?).and_return(false)
          expect(subject).to receive(:git).with(
            %|clone https://repo.com "#{cache_path}" --bare --no-hardlinks|
          )
          subject.install
        end
      end
    end

    describe '#cached_cookbook' do
      it 'returns nil if the cookbook is not installed' do
        subject.stub(:installed?).and_return(false)
        expect(subject.cached_cookbook).to be_nil
      end

      it 'returns the cookbook at the install_path' do
        subject.stub(:installed?).and_return(true)
        CachedCookbook.stub(:from_path)

        expect(CachedCookbook).to receive(:from_path).once
        subject.cached_cookbook
      end
    end

    describe '#==' do
      let(:other) { subject.dup }

      it 'returns true when everything matches' do
        expect(subject).to eq(other)
      end

      it 'returns false when the other location is not an GitLocation' do
        other.stub(:is_a?).and_return(false)
        expect(subject).to_not eq(other)
      end

      it 'returns false when the uri is different' do
        other.stub(:uri).and_return('different')
        expect(subject).to_not eq(other)
      end

      it 'returns false when the branch is different' do
        other.stub(:branch).and_return('different')
        expect(subject).to_not eq(other)
      end

      it 'returns false when the tag is different' do
        other.stub(:tag).and_return('different')
        expect(subject).to_not eq(other)
      end

      it 'returns false when the ref is different' do
        other.stub(:ref).and_return('different')
        expect(subject).to_not eq(other)
      end

      it 'returns false when the rel is different' do
        other.stub(:rel).and_return('different')
        expect(subject).to_not eq(other)
      end
    end

    describe '#to_s' do
      it 'prefers the tag' do
        expect(subject.to_s).to eq('https://repo.com (at v1.2.3/hi)')
      end

      it 'prefers the branch' do
        subject.stub(:tag).and_return(nil)
        expect(subject.to_s).to eq('https://repo.com (at ham/hi)')
      end

      it 'falls back to the ref' do
        subject.stub(:tag).and_return(nil)
        subject.stub(:branch).and_return(nil)
        expect(subject.to_s).to eq('https://repo.com (at abc123/hi)')
      end

      it 'does not use the rel if missing' do
        subject.stub(:rel).and_return(nil)
        expect(subject.to_s).to eq('https://repo.com (at v1.2.3)')
      end
    end

    describe '#to_lock' do
      it 'includes all the information' do
        expect(subject.to_lock).to eq <<-EOH.gsub(/^ {8}/, '')
            git: https://repo.com
            revision: defjkl123456
            ref: abc123
            branch: ham
            tag: v1.2.3
            rel: hi
        EOH
      end

      it 'does not include the branch if missing' do
        subject.stub(:branch).and_return(nil)
        expect(subject.to_lock).to_not include('branch')
      end

      it 'does not include the tag if missing' do
        subject.stub(:tag).and_return(nil)
        expect(subject.to_lock).to_not include('tag')
      end

      it 'does not include the rel if missing' do
        subject.stub(:rel).and_return(nil)
        expect(subject.to_lock).to_not include('rel')
      end
    end

    describe '#git' do
      before { described_class.send(:public, :git) }

      it 'raises an error if Git is not installed' do
        Berkshelf.stub(:which).and_return(false)
        expect { subject.git('foo') }.to raise_error(GitLocation::GitNotInstalled)
      end

      it 'raises an error if the command fails' do
        shell_out = double('shell_out', success?: false, stderr: nil)
        Buff::ShellOut.stub(:shell_out).and_return(shell_out)
        expect { subject.git('foo') }.to raise_error(GitLocation::GitCommandError)
      end
    end
  end
end
