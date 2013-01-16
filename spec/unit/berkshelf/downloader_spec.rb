require 'spec_helper'

module Berkshelf
  describe Downloader do
    subject { Downloader.new(CookbookStore.new(tmp_path)) }

    #
    # Class Methods
    #
    describe '.initialize' do
      context 'when no value for locations is given' do
        it 'sets the @locations instance variable to a blank array' do
          downloader = Berkshelf::Downloader.new( double('store') )

          expect(downloader.instance_variable_get(:@locations)).to be_a(Array)
          expect(downloader.instance_variable_get(:@locations)).to have(0).items
        end
      end

      context 'when an explicit value of locations is given' do
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

        it 'sets the @locations instance variable to the given locations' do
          downloader = Berkshelf::Downloader.new(double('store'), locations: locations)
          expect(downloader.instance_variable_get(:@locations)).to eql(locations)
        end
      end
    end

    #
    # Instance Methods
    #
    describe '#download' do
      let(:source) { double('source', name: 'artifact', version_constraint: '= 0.10.0') }
      let(:location) { double('location') }
      let(:cached_cookbook) { double('cached') }

      context 'when the source has a location' do
        before(:each) do
          source.stub(:location).and_return(location)
          location.should_receive(:download).with(subject.storage_path).and_return(cached_cookbook)
          source.should_receive(:cached_cookbook=).with(cached_cookbook)
        end

        it "sends :download to the source's location and sets the source's cached_cookbook to the result" do
          expect(subject.download(source)).to be_true
        end

        it 'returns an Array containing the cached_cookbook and location used to download' do
          result = subject.download(source)

          expect(result).to be_a(Array)
          expect(result[0]).to eql(cached_cookbook)
          expect(result[1]).to eql(location)
        end
      end

      context 'when the source does not have a location' do
        before(:each) do
          source.stub(:location).and_return(nil)
          subject.stub(:locations).and_return([{type: :chef_api, value: :config, options: Hash.new}])
        end

        it 'sends the :download message to the default location' do
          Location.should_receive(:init).with(source.name, source.version_constraint, chef_api: :config).and_return(location)
          location.should_receive(:download).with(subject.storage_path).and_return(cached_cookbook)
          source.should_receive(:cached_cookbook=).with(cached_cookbook)

          subject.download(source)
        end
      end

      context 'when the download fails' do
        let(:location) { double('location') }
        let(:formatter) { double('formatter') }

        before do
          source.stub(:location).and_return(location)
          location.stub(:download).with(any_args()).and_raise(Berkshelf::CookbookNotFound)
          Berkshelf.stub(:formatter).and_return(formatter)
        end

        it 'forwards the exception' do
          formatter.should_receive(:error)

          expect {
            subject.download(source)
          }.to raise_error(Berkshelf::CookbookNotFound)
        end
      end
    end

    describe '#locations' do
      let(:type) { :site }
      let(:value) { double('value') }
      let(:options) { double('options') }

      it 'returns an array of Hashes representing locations' do
        subject.add_location(type, value, options)

        subject.locations.each { |l| expect(l).to be_a(Hash) }
      end

      context 'when no locations are explicitly added' do
        subject { Downloader.new(double('store')) }

        it 'returns an array of default locations' do
          expect(subject.locations).to eql(Downloader::DEFAULT_LOCATIONS)
        end
      end

      context 'when locations are explicitly added' do
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

        it 'contains only the locations passed to the initializer' do
          expect(subject.locations).to eql(locations)
        end

        it 'does not include the array of default locations' do
          expect(subject.locations).not_to include(Downloader::DEFAULT_LOCATIONS)
        end
      end
    end

    describe '#add_location' do
      let(:type) { :site }
      let(:value) { double('value') }
      let(:options) { double('options') }

      it 'adds a hash to the end of the array of locations' do
        subject.add_location(type, value, options)

        expect(subject.locations).to have(1).item
      end

      it 'adds a hash with a type, value, and options key' do
        subject.add_location(type, value, options)

        expect(subject.locations.last).to have_key(:type)
        expect(subject.locations.last).to have_key(:value)
        expect(subject.locations.last).to have_key(:options)
      end

      it "sets the value of the given 'value' to the value of the key 'value'" do
        subject.add_location(type, value, options)

        expect(subject.locations.last[:value]).to eql(value)
      end

      it "sets the value of the given 'type' to the value of the key 'type'" do
        subject.add_location(type, value, options)

        expect(subject.locations.last[:type]).to eql(type)
      end

      it "sets the value of the given 'options' to the value of the key 'options'" do
        subject.add_location(type, value, options)

        expect(subject.locations.last[:options]).to eql(options)
      end

      it 'raises a DuplicateLocationDefined error if a location of the given type and value was already added' do
        subject.add_location(type, value, options)

        expect {
          subject.add_location(type, value, options)
        }.to raise_error(DuplicateLocationDefined)
      end

      context 'adding multiple locations' do
        let(:type_2) { :site }
        let(:value_2) { double('value_2') }
        let(:options_2) { double('options_2') }

        it 'adds locations in the order they are added' do
          subject.add_location(type, value, options)
          subject.add_location(type_2, value_2, options_2)

          expect(subject.locations).to have(2).items

          expect(subject.locations[0][:value]).to eql(value)
          expect(subject.locations[1][:value]).to eql(value_2)
        end
      end
    end

    describe '#has_location?' do
      let(:type) { :site }
      let(:value) { double('value') }

      it 'returns true if a source of the given type and value was already added' do
        subject.add_location(type, value)

        expect(subject.has_location?(type, value)).to be_true
      end

      it 'returns false if a source of the given type and value was not added' do
        expect(subject.has_location?(type, value)).to be_false
      end
    end
  end
end
