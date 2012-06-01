require 'spec_helper'

module KnifeCookbookDependencies
  describe Shelf do
    describe '#exclude' do
      it "should split on :" do
        subject.exclude("foo:bar")
        subject.excluded_groups.should == [:foo, :bar]
      end

      it "should split on ," do
        subject.exclude("foo,bar")
        subject.excluded_groups.should == [:foo, :bar]
      end

      it "should take an Array" do
        subject.exclude(["foo","bar"])
        subject.excluded_groups.should == [:foo, :bar]
      end
    end

    describe '#groups' do
      before(:each) do
        subject.add_source CookbookSource.new("foobar", :group => ["foo", "bar"])
        subject.add_source CookbookSource.new("baz", :group => "baz")
        subject.add_source CookbookSource.new("quux", :group => "quux")
        subject.add_source CookbookSource.new("baz2", :group => "baz")
        @groups = subject.groups
      end

      it "should return a hash of groups and associated cookbooks" do
        @groups.keys.size.should == 4
        @groups[:foo].should == ["foobar"]
        @groups[:bar].should == ["foobar"]
        @groups[:baz].should == ["baz", "baz2"]
        @groups[:quux].should == ["quux"]
      end
    end

    describe "#add_source" do
      let(:cookbook_source) { CookbookSource.new("mysql", "= 1.2.4") }
      before(:each) { subject.add_source(cookbook_source) }

      it "should add the given source to the sources" do
        subject.should have_source(cookbook_source)
      end
    end

    describe "#remove_source" do
      let(:cookbook_source) { CookbookSource.new("mysql", "= 1.2.4") }

      before(:each) do
        subject.add_source(cookbook_source)  
      end

      it "should remove the given source from the sources" do
        subject.remove_source(cookbook_source)

        subject.should_not have_source(cookbook_source)
      end
    end

    describe "#has_source?" do
      let(:cookbook_source) { CookbookSource.new("sparkle_motion") }
      let(:invalid_source) { CookbookSource.new("invalid") }

      before(:each) do
        subject.add_source(cookbook_source)
      end

      it "should return true if the source is a member of this Shelf" do
        subject.has_source?(cookbook_source).should be_true
      end

      it "should return false if the source is not a member of this Shelf" do
        subject.has_source?(invalid_source).should be_false
      end

      it "should accept a string for the identifier" do
        subject.has_source?("sparkle_motion").should be_true
      end

      it "should accept an instance of CookbookSource for the identifier" do
        subject.has_source?(cookbook_source).should be_true
      end
    end

    describe "#download_sources" do
      let(:cookbook_source) { CookbookSource.new("mysql", "= 1.2.4") }
      before(:each) do
        subject.add_source(cookbook_source)
      end

      it "should download all sources to a local path on disk" do
        subject.download_sources

        cookbook_source.should be_downloaded
      end
    end
  end
end
