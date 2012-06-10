require 'spec_helper'

module KnifeCookbookDependencies
  describe CachedCookbook do
    describe "ClassMethods" do
      subject { CachedCookbook }

      describe "#from_path" do
        before(:each) do
          @cached_cb = subject.from_path(fixtures_path.join("cookbooks", "example_cookbook-0.5.0"))
        end

        it "returns an instance of CachedCookbook" do
          @cached_cb.should be_a(CachedCookbook)
        end

        it "sets a version number" do
          @cached_cb.version.should eql("0.5.0")
        end

        context "given a path that does not contain a cookbook" do
          it "returns nil" do
            subject.from_path(tmp_path).should be_nil
          end
        end

        context "given a path that does not match the CachedCookbook dirname format" do
          it "returns nil" do
            subject.from_path(fixtures_path.join("cookbooks", "example_cookbook")).should be_nil
          end
        end
      end
    end
  end
end
