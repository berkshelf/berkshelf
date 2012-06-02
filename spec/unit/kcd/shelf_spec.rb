require 'spec_helper'

module KnifeCookbookDependencies
  describe Shelf do
    let(:source_one) { CookbookSource.new("nginx", :group => ["foo", "bar"]) }
    let(:source_two) { CookbookSource.new("mysql", :group => "baz") }
    let(:source_three) { CookbookSource.new("ntp", :group => "baz") }
    let(:source_four) { CookbookSource.new("sparkle_motion", :group => "quux") }

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

    describe "#sources" do
      before(:each) do
        subject.add_source source_one
        subject.add_source source_two
        subject.add_source source_three
        subject.add_source source_four
      end

      it "returns all of the sources" do
        subject.sources.should have(4).sources
      end

      context "when given the option :permitted" do
        it "returns only sources belonging to no groups or groups that have not been excluded" do
          subject.exclude(["foo", "bar", "baz"])

          subject.sources(:permitted).should include(source_four)
        end
      end

      context "when given the option :excluded" do
        it "returns only sources that belong to groups that have been exclued" do
          subject.exclude(["quux"])

          subject.sources(:excluded).should include(source_four)
        end
      end
    end

    describe '#groups' do
      let(:source) { CookbookSource.new("nginx", :group => ["sparkle_motion"]) }
      before(:each) do
        subject.add_source source
      end

      it "contains only groups added by association of CookbookSources" do
        subject.groups.should have(1).group
      end

      it "adds the associated CookbookSource to the members of the group" do
        subject.groups[:sparkle_motion].should include(source)
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
