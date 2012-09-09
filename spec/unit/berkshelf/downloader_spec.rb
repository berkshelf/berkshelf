require 'spec_helper'

module Berkshelf
  describe Downloader do
    subject { Downloader.new(CookbookStore.new(tmp_path)) }
    let(:source) { CookbookSource.new("sparkle_motion") }

    describe "#enqueue" do
      it "should add a source to the queue" do
        subject.enqueue(source)

        subject.queue.should have(1).source
      end

      it "should not allow you to add an invalid source" do
        lambda {
          subject.enqueue("a string, not a source")
        }.should raise_error(ArgumentError)
      end
    end

    describe "#dequeue" do
      before(:each) { subject.enqueue(source) }

      it "should remove a source from the queue" do
        subject.dequeue(source)

        subject.queue.should be_empty
      end
    end

    describe "#download_all" do
      let(:source_one) { CookbookSource.new("nginx") }
      let(:source_two) { CookbookSource.new("mysql") }

      before(:each) do
        subject.enqueue source_one
        subject.enqueue source_two
      end

      it "should remove each item from the queue after a successful download" do
        subject.download_all

        subject.queue.should be_empty
      end

      it "should not remove the item from the queue if the download failed" do
        subject.enqueue CookbookSource.new("does_not_exist_no_way")
        subject.download_all

        subject.queue.should have(1).sources
      end

      it "should return a TXResultSet" do
        results = subject.download_all

        results.should be_a(TXResultSet)
      end
    end

    describe "#download" do
      let(:source) { CookbookSource.new("nginx") }
      let(:bad_source) { CookbookSource.new("donowaytexists") }

      it "returns a TXResult" do
        subject.download(source).should be_a(TXResult)
      end

      context "when successful" do
        it "returns a successesful TXResult" do
          subject.download(source).should be_success
        end
      end

      context "when failure" do
        it "returns a failed TXResult" do
          subject.download(bad_source).should be_failed
        end
      end
    end

    describe "#add_location" do
      let(:type) { :site }
      let(:value) { double('value') }
      let(:options) { double('options') }

      it "adds a hash to the end of the array of locations" do
        subject.add_location(type, value, options)

        subject.locations.should have(1).item
      end

      it "adds a hash with a type, value, and options key" do
        subject.add_location(type, value, options)

        subject.locations.last.should have_key(:type)
        subject.locations.last.should have_key(:value)
        subject.locations.last.should have_key(:options)
      end

      it "sets the value of the given 'value' to the value of the key 'value'" do
        subject.add_location(type, value, options)

        subject.locations.last[:value].should eql(value)
      end

      it "sets the value of the given 'type' to the value of the key 'type'" do
        subject.add_location(type, value, options)

        subject.locations.last[:type].should eql(type)
      end

      it "sets the value of the given 'options' to the value of the key 'options'" do
        subject.add_location(type, value, options)

        subject.locations.last[:options].should eql(options)
      end

      it "raises a DuplicateLocationDefined error if a location of the given type and value was already added" do
        subject.add_location(type, value, options)

        lambda {
          subject.add_location(type, value, options)
        }.should raise_error(DuplicateLocationDefined)
      end

      context "adding multiple locations" do
        let(:type_2) { :site }
        let(:value_2) { double('value_2') }
        let(:options_2) { double('options_2') }

        it "adds locations in the order they are added" do
          subject.add_location(type, value, options)
          subject.add_location(type_2, value_2, options_2)

          subject.locations[0][:value].should eql(value)
          subject.locations[1][:value].should eql(value_2)
        end
      end
    end

    describe "#has_location?" do
      let(:type) { :site }
      let(:value) { double('value') }

      it "returns true if a source of the given type and value was already added" do
        subject.stub(:locations) { [ { type: type, value: value, options: Hash.new } ] }

        subject.has_location?(type, value).should be_true
      end

      it "returns false if a source of the given type and value was not added" do
        subject.has_location?(type, value).should be_false
      end
    end
  end
end
