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

    describe "#satisfy" do
      let(:name) { "nginx" }
      let(:version) { "0.101.4" }
      let(:constraint) { Solve::Constraint.new("~> 0.101.2") }
      let(:cached_cb) { double('cached-cb', name: name, version: Solve::Version.new(version)) }
      let(:cached_two) { double('cached-two', name: "mysql", version: Solve::Version.new("1.2.6")) }

      before(:each) do
        subject.stub(:cookbooks).and_return([cached_cb, cached_two])
      end

      it "gets and returns the the CachedCookbook best matching the name and constraint" do
        subject.should_receive(:cookbook).with(name, version).and_return(cached_cb)

        subject.satisfy(name, constraint).should eql(cached_cb)
      end

      context "when there are no cookbooks in the cookbook store" do
        before(:each) { subject.stub(:cookbooks).and_return([]) }

        it "returns nil" do
          subject.satisfy(name, constraint).should be_nil
        end
      end

      context "when there is no matching cookbook for the given name and constraint" do
        let(:version) { Solve::Version.new("1.0.0") }
        let(:constraint) { Solve::Constraint.new("= 0.1.0") }

        before(:each) do
          subject.stub(:cookbooks).and_return([ double('badcache', name: 'none', version: version) ])
        end

        it "returns nil if there is no matching cookbook for the name and constraint" do
          subject.satisfy(name, constraint).should be_nil
        end
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
      before(:each) do
        generate_cookbook(subject.storage_path, "nginx", "0.101.2")
        generate_cookbook(subject.storage_path, "mysql", "1.2.6")
      end

      it "returns a list of CachedCookbooks" do
        subject.cookbooks.each do |cb|
          cb.should be_a(CachedCookbook)
        end
      end

      it "contains a CachedCookbook for every cookbook in the storage path" do
        subject.cookbooks.should have(2).items
      end

      context "given a value for the filter parameter" do
        it "returns only the CachedCookbooks whose name match the filter" do
          subject.cookbooks("mysql").should have(1).item
        end
      end
    end
  end
end
