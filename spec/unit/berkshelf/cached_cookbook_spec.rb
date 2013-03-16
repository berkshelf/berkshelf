require 'spec_helper'

describe Berkshelf::CachedCookbook do
  describe "ClassMethods" do
    subject { described_class }

    describe "#from_store_path" do
      before(:each) do
        @cached_cb = subject.from_store_path(fixtures_path.join("cookbooks", "example_cookbook-0.5.0"))
      end

      it "returns an instance of CachedCookbook" do
        @cached_cb.should be_a(described_class)
      end

      it "sets a version number" do
        @cached_cb.version.should eql("0.5.0")
      end

      it "sets the metadata.name value to the cookbook_name" do
        @cached_cb.metadata.name.should eql("example_cookbook")
      end

      context "given a path that does not contain a cookbook" do
        it "returns nil" do
          subject.from_store_path(tmp_path).should be_nil
        end
      end

      context "given a path that does not match the CachedCookbook dirname format" do
        it "returns nil" do
          subject.from_store_path(fixtures_path.join("cookbooks", "example_cookbook")).should be_nil
        end
      end
    end

    describe "#checksum" do
      it "returns a checksum of the given filepath" do
        subject.checksum(fixtures_path.join("cookbooks", "example_cookbook-0.5.0", "README.md")).should eql("6e21094b7a920e374e7261f50e9c4eef")
      end

      context "given path does not exist" do
        it "raises an Errno::ENOENT error" do
          lambda {
            subject.checksum(fixtures_path.join("notexisting.file"))
          }.should raise_error(Errno::ENOENT)
        end
      end
    end
  end

  describe "#dependencies" do
    let(:dependencies) { { "mysql" => "= 1.2.0", "ntp" => ">= 0.0.0" } }
    let(:recommendations) { { "database" => ">= 0.0.0" } }

    let(:cb_path) do
      generate_cookbook(Berkshelf.cookbook_store.storage_path, "sparkle", "0.1.0", dependencies: dependencies, recommendations: recommendations)
    end

    subject { described_class.from_store_path(cb_path) }

    it "contains depends from the cookbook metadata" do
      subject.dependencies.should include(dependencies)
    end

    it "contains recommendations from the cookbook metadata" do
      subject.dependencies.should include(recommendations)
    end
  end
end
