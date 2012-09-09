require 'spec_helper'

module Berkshelf
  describe Downloader do 
    subject { Downloader.new(CookbookStore.new(tmp_path)) }

    describe "#download" do
      let(:source) { double('source', name: "artifact", version_constraint: "= 0.10.0") }
      let(:location) { double('location') }
      let(:cached_cookbook) { double('cached') }

      context "when the source has a location" do
        it "sends 'download' to the source's location and sets the source's cached_cookbook to the result" do
          source.stub(:location).and_return(location)
          location.should_receive(:download).with(subject.storage_path).and_return(cached_cookbook)
          source.should_receive(:cached_cookbook=).with(cached_cookbook)
          
          subject.download(source).should be_true
        end
      end

      context "when the source does not have a location" do
        context "and there are no default locations set" do
          it "creates a default location with the given source and sends it 'download'" do
            source.stub(:location).and_return(nil)
            subject.stub(:locations).and_return(Array.new)
            CookbookSource::Location.should_receive(:init).with(source.name, source.version_constraint).and_return(location)
            location.should_receive(:download).with(subject.storage_path).and_return(cached_cookbook)
            source.should_receive(:cached_cookbook=).with(cached_cookbook)

            subject.download(source).should be_true
          end
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
