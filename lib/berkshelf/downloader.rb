module Berkshelf
  # @author Jamie Winsor <reset@riotgames.com>
  class Downloader
    extend Forwardable

    DEFAULT_LOCATIONS = [
      {
        type: :site,
        value: Location::OPSCODE_COMMUNITY_API,
        options: Hash.new
      }
    ]

    # @return [String]
    #   a filepath to download cookbook sources to
    attr_reader :cookbook_store

    def_delegators :@cookbook_store, :storage_path

    # @option options [Array<Hash>] locations
    def initialize(cookbook_store, options = {})
      @cookbook_store = cookbook_store
      @locations = options.fetch(:locations, Array.new)
    end

    # @return [Array<Hash>]
    #   an Array of Hashes representing each default location that can be used to attempt
    #   to download cookbook sources which do not have an explicit location. An array of default locations will
    #   be used if no locations are explicitly added by the {#add_location} function.
    def locations
      @locations.any? ? @locations : DEFAULT_LOCATIONS
    end

    # Create a location hash and add it to the end of the array of locations.
    #
    # subject.add_location(:chef_api, "http://chef:8080", node_name: "reset", client_key: "/Users/reset/.chef/reset.pem") =>
    #   [ { type: :chef_api, value: "http://chef:8080/", node_name: "reset", client_key: "/Users/reset/.chef/reset.pem" } ]
    #
    # @param [Symbol] type
    # @param [String, Symbol] value
    # @param [Hash] options
    #
    # @return [Hash]
    def add_location(type, value, options = {})
      if has_location?(type, value)
        raise DuplicateLocationDefined,
          "A default '#{type}' location with the value '#{value}' is already defined"
      end

      @locations.push(type: type, value: value, options: options)
    end

    # Checks the list of default locations if a location of the given type and value has already
    # been added and returns true or false.
    #
    # @return [Boolean]
    def has_location?(type, value)
      @locations.select { |loc| loc[:type] == type && loc[:value] == value }.any?
    end

    # Downloads the given CookbookSource.
    #
    # @param [CookbookSource] source
    #   the source to download
    #
    # @return [Array]
    #   an array containing the downloaded CachedCookbook and the Location used
    #   to download the cookbook
    def download(source)
      cached_cookbook, location = if source.location
        begin
          [source.location.download(storage_path), source.location]
        rescue CookbookValidationFailure; raise
        rescue
          Berkshelf.formatter.error "Failed to download '#{source.name}' from #{source.location}"
          raise
        end
      else
        search_locations(source)
      end

      source.cached_cookbook = cached_cookbook

      [cached_cookbook, location]
    end

    private

      # Searches locations for a CookbookSource. If the source does not contain a
      # value for {CookbookSource#location}, the default locations of this
      # downloader will be used to attempt to retrieve the source.
      #
      # @param [CookbookSource] source
      #   the source to download
      #
      # @return [Array]
      #   an array containing the downloaded CachedCookbook and the Location used
      #   to download the cookbook
      def search_locations(source)
        cached_cookbook = nil
        location = nil

        locations.each do |loc|
          location = Location.init(
            source.name,
            source.version_constraint,
            loc[:options].merge(loc[:type] => loc[:value])
          )
          begin
            cached_cookbook = location.download(storage_path)
            break
          rescue Berkshelf::CookbookNotFound
            cached_cookbook, location = nil
            next
          end
        end

        if cached_cookbook.nil?
          raise CookbookNotFound, "Cookbook '#{source.name}' not found in any of the default locations"
        end

        [ cached_cookbook, location ]
      end


      # Validates that a source is an instance of CookbookSource
      #
      # @param [CookbookSource] source
      #
      # @return [Boolean]
      def validate_source(source)
        source.is_a?(Berkshelf::CookbookSource)
      end
  end
end
