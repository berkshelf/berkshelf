module Berkshelf
  # @author Jamie Winsor <jamie@vialstudios.com>
  class Downloader
    extend Forwardable

    DEFAULT_LOCATION = {
      type: :site,
      value: :opscode,
      options: Hash.new
    }.freeze

    # @return [String]
    #   a filepath to download cookbook sources to
    attr_reader :cookbook_store
    
    # @return [Array<Hash>]
    #   an Array of Hashes representing each default location that can be used to attempt
    #   to download cookbook sources which do not have an explicit location
    attr_reader :locations

    def_delegators :@cookbook_store, :storage_path

    # @option options [Array<Hash>] locations
    def initialize(cookbook_store, options = {})
      @cookbook_store = cookbook_store
      @locations = options[:locations] || Array.new
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
        raise DuplicateLocationDefined, "A default location of type: #{type} and value: #{value} is already defined"
      end
      
      locations.push(type: type, value: value, options: options)
    end

    # Checks the list of default locations if a location of the given type and value has already
    # been added and returns true or false.
    #
    # @return [Boolean]
    def has_location?(type, value)
      !locations.select { |loc| loc[:type] == type && loc[:value] == value }.empty?
    end

    # Downloads the given CookbookSource
    #
    # @param [CookbookSource] source
    #   the source to download
    #
    # @return [Boolean]
    def download(source)
      source.cached_cookbook = if source.location
        source.location.download(storage_path)
      else
        # JW TODO: use default sources to download
        location = CookbookSource::Location.init(source.name, source.version_constraint)
        location.download(storage_path)
      end

      true
    end

    private

      def validate_source(source)
        source.is_a?(Berkshelf::CookbookSource)
      end
  end
end
