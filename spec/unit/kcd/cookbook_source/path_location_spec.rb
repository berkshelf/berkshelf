require 'spec_helper'

module KnifeCookbookDependencies
  describe CookbookSource::PathLocation do
    let(:path) { fixtures_path.join("cookbooks", "example_cookbook").to_s }
    subject { CookbookSource::PathLocation.new("nginx", :path => path) }

    describe "#download" do
      it "returns the path to the cookbook" do
        subject.download(tmp_path).should eql(path)
      end

      context "given a path that does not exist" do
        subject { CookbookSource::PathLocation.new("doesnot_exist", :path => tmp_path.join("doesntexist_noway")) }

        it "raises a CookbookNotFound error" do
          lambda {
            subject.download(tmp_path)
          }.should raise_error(CookbookNotFound)
        end
      end

      context "given a path that does not contain a cookbook" do
        subject { CookbookSource::PathLocation.new("doesnot_exist", :path => fixtures_path) }

        it "raises a CookbookNotFound error" do
          lambda {
            subject.download(tmp_path)
          }.should raise_error(CookbookNotFound)
        end
      end
    end
  end
end
