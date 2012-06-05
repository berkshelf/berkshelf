require 'spec_helper'

module KnifeCookbookDependencies
  describe Resolver do
    let(:source) { CookbookSource.new("mysql", "= 1.2.4") }

    subject do
      downloader = Downloader.new(tmp_path)
      Resolver.new(downloader)
    end

    describe "#add_source" do
      before(:each) { subject.add_source(source) }

      it "adds the source to the instance of resolver" do
        subject.sources.should include(source)
      end

      it "raises a DuplicateSourceDefined exception if a source of the same name is added" do
        dup_source = CookbookSource.new(source.name)

        lambda {
          subject.add_source(dup_source)
        }.should raise_error(DuplicateSourceDefined)
      end
    end

    describe "#add_source_dependency" do
      before(:each) do
        subject.add_source(source)
        @dependencies = source.dependency_sources
        @dependencies.each do |dep|
          subject.add_source_dependency(dep)
        end
      end

      it "adds the dependencies of the source as sources" do
        @dependencies.each do |dep|
          subject.should have_source(dep.name)
        end
      end

      it "doesn't overwrite a source that has already been set" do
        dup_source = CookbookSource.new(source.name).clone

        subject.add_source_dependency(dup_source)

        subject[source.name].should === source
      end
    end

    describe "#[]" do
      before(:each) { subject.add_source(source) }

      it "returns the source of the given name" do
        subject[source.name].should eql(source)
      end
    end

    describe "#has_source?" do
      before(:each) { subject.add_source(source) }

      it "returns the source of the given name" do
        subject.has_source?(source.name).should be_true
      end
    end

    describe "#resolve" do
      before(:each) { subject.add_source(source) }
      
      it "fucks up" do
        subject.resolve.should eql("mysql" => DepSelector::Version.new("1.2.4"), "openssl" => DepSelector::Version.new("1.0.0"))
      end
    end
  end
end
