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
end
