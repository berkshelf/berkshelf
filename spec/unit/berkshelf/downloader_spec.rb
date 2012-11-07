require 'spec_helper'

module Berkshelf
  describe Downloader do
    describe "ClassMethods" do
      subject { Downloader }

      describe "::initialize" do
        context "when no value for locations is given" do
          it "sets the @locations instance variable to a blank array" do
            downloader = subject.new(double('store'))

            downloader.instance_variable_get(:@locations).should be_a(Array)
            downloader.instance_variable_get(:@locations).should have(0).items
          end
        end

        context "when an explicit value of locations is given" do
          let(:locations) do
            [
              {
                type: :chef_api,
                value: double('capi'),
                options: double('capi_opts')
              },
              {
                type: :chef_api,
                value: double('capi2'),
                options: double('capi_opts2')
              }
            ]
          end

          it "sets the @locations instance variable to the given locations" do
            downloader = subject.new(double('store'), locations: locations)

            downloader.instance_variable_get(:@locations).should eql(locations)
          end
        end
      end
    end

    subject { Downloader.new(CookbookStore.new(tmp_path)) }

    describe "#download" do
      let(:source) { double('source', name: "artifact", version_constraint: "= 0.10.0") }
      let(:location) { double('location') }
      let(:cached_cookbook) { double('cached') }

      context "when the source has a location" do
        before(:each) do
          source.stub(:location).and_return(location)
          location.should_receive(:download).with(subject.storage_path).and_return(cached_cookbook)
          source.should_receive(:cached_cookbook=).with(cached_cookbook)
        end

        it "sends 'download' to the source's location and sets the source's cached_cookbook to the result" do
          subject.download(source).should be_true
        end

        it "returns an Array containing the cached_cookbook and location used to download" do
          result = subject.download(source)

          result.should be_a(Array)
          result[0].should eql(cached_cookbook)
          result[1].should eql(location)
        end
      end

      context "when the source does not have a location" do
        before(:each) do
          source.stub(:location).and_return(nil)
          subject.stub(:locations).and_return([{type: :chef_api, value: :config, options: Hash.new}])
        end

        it "sends the 'download' message to the default location" do
          Location.should_receive(:init).with(source.name, source.version_constraint, chef_api: :config).and_return(location)
          location.should_receive(:download).with(subject.storage_path).and_return(cached_cookbook)
          source.should_receive(:cached_cookbook=).with(cached_cookbook)

          subject.download(source)
        end
      end
    end

    describe "#locations" do
      let(:type) { :site }
      let(:value) { double('value') }
      let(:options) { double('options') }

      it "returns an array of Hashes representing locations" do
        subject.add_location(type, value, options)

        subject.locations.each { |l| l.should be_a(Hash) }
      end

      context "when no locations are explicitly added" do
        subject { Downloader.new(double('store')) }

        it "returns an array of default locations" do
          subject.locations.should eql(Downloader::DEFAULT_LOCATIONS)
        end
      end

      context "when locations are explicitly added" do
        let(:locations) do
          [
            {
              type: :chef_api,
              value: double('capi'),
              options: double('capi_opts')
            },
            {
              type: :chef_api,
              value: double('capi2'),
              options: double('capi_opts2')
            }
          ]
        end

        subject { Downloader.new(double('store'), locations: locations) }

        it "contains only the locations passed to the initializer" do
          subject.locations.should eql(locations)
        end

        it "does not include the array of default locations" do
          subject.locations.should_not include(Downloader::DEFAULT_LOCATIONS)
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

          subject.locations.should have(2).items

          subject.locations[0][:value].should eql(value)
          subject.locations[1][:value].should eql(value_2)
        end
      end
    end

    describe "#has_location?" do
      let(:type) { :site }
      let(:value) { double('value') }

      it "returns true if a source of the given type and value was already added" do
        subject.add_location(type, value)

        subject.has_location?(type, value).should be_true
      end

      it "returns false if a source of the given type and value was not added" do
        subject.has_location?(type, value).should be_false
      end
    end
  end
end
