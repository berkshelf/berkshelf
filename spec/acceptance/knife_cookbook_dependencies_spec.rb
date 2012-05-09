require 'spec_helper'

describe "knife cookbook dependencies install" do
  describe "should print a friendly error message" do
    # TODO: Fixme
    it "for missing cookbooks" do
      with_cookbookfile %q[cookbook "cantfindthisone"] do
        `knife cookbook dependencies install 2>&1`.should match(/#{KnifeCookbookDependencies::ErrorMessages.missing_cookbook('cantfindthisone')}/)
      end
    end
    it "for missing Cookbookfile"
  end
end
