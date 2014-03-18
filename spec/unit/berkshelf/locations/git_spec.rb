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

      context 'ref' do
        it 'uses the :ref option with priority' do
          instance = described_class.new(dependency,
            git: 'https://repo.com', ref: 'abc123', branch: 'magic_new_feature')
          expect(instance.ref).to eq('abc123')
        end

        it 'uses the :branch option with priority' do
          instance = described_class.new(dependency,
            git: 'https://repo.com', branch: 'magic_new_feature', tag: 'v1.2.3')
          expect(instance.ref).to eq('magic_new_feature')
        end

        it 'uses the :tag option' do
          instance = described_class.new(dependency,
            git: 'https://repo.com', tag: 'v1.2.3')
          expect(instance.ref).to eq('v1.2.3')
        end

        it 'uses "master" when none is given' do
          instance = described_class.new(dependency, git: 'https://repo.com')
          expect(instance.ref).to eq('master')
        end
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
    end

    describe '#download' do
      before do
        CachedCookbook.stub(:from_store_path)
        FileUtils.stub(:cp_r)
        subject.stub(:validate_cached!)
        subject.stub(:validate_cookbook!)
        subject.stub(:git)
      end

      context 'when the cookbook is already installed' do
        it 'loads the cookbook from the store' do
          subject.stub(:installed?).and_return(true)
          expect(CachedCookbook).to receive(:from_store_path)
          expect(subject).to receive(:validate_cached!)
          expect(subject).to_not receive(:git)
          subject.download
        end
      end

      context 'when the repository is cached' do
        it 'pulls a new version' do
          Dir.stub(:chdir) { |args, &b| b.call } # Force eval the chdir block

          subject.stub(:cached?).and_return(true)
          expect(subject).to receive(:git).with('fetch --all')
          subject.download
        end
      end

      context 'when the revision is not cached' do
        it 'clones the repository' do
          subject.stub(:cached?).and_return(false)
          expect(subject).to receive(:git).with('clone https://repo.com .')
          subject.download
        end
      end
    end

    describe '#scm_location?' do
      it 'returns true' do
        instance = described_class.new(dependency, git: 'https://repo.com')
        expect(instance).to be_scm_location
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
        subject.stub(:`)
        $?.stub(:success?).and_return(false)
        expect { subject.git('foo') }.to raise_error(GitLocation::GitCommandError)
      end
    end
  end
end
