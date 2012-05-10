require 'spec_helper'
require 'chef/knife/cookbook_dependencies_install'
require 'aruba/api'


describe "knife cookbook dependencies install" do
  describe "should print a friendly error message" do
    include Aruba::Api

    it "for missing cookbooks" do
      pending "Knife commands produce no output when run with aruba. I'm not sure why." # TODO FIXME

      cookbook_name = 'thisisamissingcookbook'
      with_cookbookfile %Q[cookbook "#{cookbook_name}"] do
        cmd = 'cat nofile' #'knife cookbook dependencies install'
        process = run(cmd)
        process.output(true).should match(/#{KnifeCookbookDependencies::ErrorMessages.missing_cookbook(cookbook_name)}/)
      end
    end
    it "for missing Cookbookfile"
  end
end
