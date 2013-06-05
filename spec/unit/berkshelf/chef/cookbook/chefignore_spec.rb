require 'spec_helper'

describe Berkshelf::Chef::Cookbook::Chefignore do
  describe '.find_relative_to' do
    let(:path) { tmp_path.join('chefignore-test') }
    before(:each) { FileUtils.mkdir_p(path) }

    it "finds a chefignore file in a 'cookbooks' directory relative to the given path" do
      FileUtils.touch(path.join('chefignore'))
      Berkshelf::Chef::Cookbook::Chefignore.find_relative_to(path)
    end

    it 'finds a chefignore file relative to the given path' do
      FileUtils.mkdir_p(path.join('cookbooks'))
      FileUtils.touch(path.join('cookbooks', 'chefignore'))
      Berkshelf::Chef::Cookbook::Chefignore.find_relative_to(path)
    end
  end

  subject { described_class.new('/foo/bar') }

  describe '#to_s' do
    it 'includes the berkshelf path' do
      expect(subject.to_s).to eq("#<Berkshelf::Chef::Cookbook::Chefignore /foo/bar/chefignore>")
    end
  end

  describe '#inspect' do
    it 'includes the cookbooks directory' do
      expect(subject.inspect).to eq("#<Berkshelf::Chef::Cookbook::Chefignore /foo/bar/chefignore, ignores: []>")
    end
  end
end
