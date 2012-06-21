require 'spec_helper'

module Berkshelf
  describe CookbookStore do
    subject { CookbookStore.new(tmp_path.join("cbstore_rspec")) }

    describe "#initialize" do
      it "creates the storage_path" do
        storage_path = tmp_path.join("random_storage")
        subject.class.new(storage_path)

        storage_path.should exist
      end
    end

    describe "#cookbook_path" do
      let(:cookbook_name) { "nginx" }
      let(:cookbook_version) { "0.101.2" }

      before(:each) do
        @cb_path = subject.cookbook_path(cookbook_name, cookbook_version)
      end

      it "returns an instance of Pathname" do
        @cb_path.should be_a(Pathname)
      end

      it "returns a Cookbook Version's filepath within the storage path" do
        @cb_path.dirname.should eql(subject.storage_path)
      end

      it "returns a basename containing the cookbook name and version separated by a dash" do
        @cb_path.basename.to_s.should eql("#{cookbook_name}-#{cookbook_version}")
      end
    end

    describe "#downloaded?" do
      it "returns true if the store contains a Cookbook of the given name and version" do
        CookbookSource.new("nginx", "0.101.2").download(subject.storage_path)

        subject.downloaded?("nginx", "0.101.2").should be_true
      end

      it "returns false if the store does not contain a Cookbook of the given name and version" do
        subject.downloaded?("notthere", "0.0.0").should be_false
      end
    end

    describe "#cookbook" do
      subject { CookbookStore.new(fixtures_path.join("cookbooks")) }

      it "returns a CachedCookbook if the specified cookbook version exists" do
        subject.cookbook("example_cookbook", "0.5.0").should be_a(CachedCookbook)
      end

      it "returns nil if the specified cookbook version does not exist" do
        subject.cookbook("doesnotexist", "0.1.0").should be_nil
      end
    end

    describe "#cookbooks" do
      it "returns a list of CachedCookbooks" do
        CookbookSource.new("nginx", "0.101.2").download(subject.storage_path)

        subject.cookbooks.each do |cb|
          cb.should be_a(CachedCookbook)
        end
      end
    end
  end
end
