require 'spec_helper'

describe Berkshelf::PathLocation do
  let(:complacent_constraint) { double('comp-vconstraint', satisfies?: true) }
  let(:path) { fixtures_path.join("cookbooks", "example_cookbook").to_s }

  subject { described_class.new("nginx", complacent_constraint, path: path) }

  describe "#download" do
    it "returns an instance of CachedCookbook" do
      subject.download(tmp_path).should be_a(Berkshelf::CachedCookbook)
    end

    it "sets the downloaded status to true" do
      subject.download(tmp_path)

      subject.should be_downloaded
    end

    context "given a path that does not exist" do
      subject { described_class.new("doesnot_exist", complacent_constraint, path: tmp_path.join("doesntexist_noway")) }

      it "raises a CookbookNotFound error" do
        lambda {
          subject.download(tmp_path)
        }.should raise_error(Berkshelf::CookbookNotFound)
      end
    end

    context "given a path that does not contain a cookbook" do
      subject { described_class.new("doesnot_exist", complacent_constraint, path: fixtures_path) }

      it "raises a CookbookNotFound error" do
        lambda {
          subject.download(tmp_path)
        }.should raise_error(Berkshelf::CookbookNotFound)
      end
    end

    context "given the content at path does not satisfy the version constraint" do
      subject { described_class.new("nginx", double('constraint', satisfies?: false), path: path) }

      it "raises a CookbookValidationFailure error" do
        lambda {
          subject.download(double('path'))
        }.should raise_error(Berkshelf::CookbookValidationFailure)
      end
    end
  end
end
