require 'spec_helper'

describe "knife cookbook dependencies install" do
  describe "should print a friendly error message" do
    # TODO: Fixme
    it "for missing cookbooks" do
      pending
      cookbook_name = 'thisisamissingcookbook'
      with_cookbookfile %Q[cookbook "#{cookbook_name}"] do
        `knife cookbook dependencies install 2>&1`.should match(/#{KnifeCookbookDependencies::ErrorMessages.missing_cookbook(cookbook_name)}/)
      end
    end
    it "for missing Cookbookfile"
  end
end
