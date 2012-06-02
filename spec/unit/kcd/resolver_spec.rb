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
