require 'spec_helper'

module Berkshelf
  describe GithubLocation do
    let(:dependency) { double(name: 'bacon') }

    describe '.initialize' do
      context 'with no explicit protocol' do
        it 'sets a git github url' do
          instance = described_class.new(dependency, github: 'meat/bacon')
          expect(instance.uri).to eq 'git://github.com/meat/bacon.git'
        end
      end

      context 'with the protocol option set to ssh' do
        it 'sets an ssh github url' do
          instance = described_class.new(dependency, github: 'meat/bacon', protocol: :ssh)
          expect(instance.uri).to eq 'ssh://git@github.com/meat/bacon.git'
        end
      end

      context 'with the protocol option set to https' do
        it 'sets an https github url' do
          instance = described_class.new(dependency, github: 'meat/bacon', protocol: :https)
          expect(instance.uri).to eq 'https://github.com/meat/bacon.git'
        end
      end
    end
  end
end

