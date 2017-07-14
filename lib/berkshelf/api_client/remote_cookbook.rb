require "json"
require "chef/mash"

module Berkshelf::APIClient
  # A representation of cookbook metadata indexed by a Berkshelf API Server. Returned
  # by sending messages to a {Berkshelf::APIClient} and used to download cookbooks
  # indexed by the Berkshelf API Server.
  class RemoteCookbook
    # @return [String]
    attr_reader :name
    # @return [String]
    attr_reader :version

    # @param [String] name
    # @param [String] version
    # @param [Hash] attributes
    def initialize(name, version, attributes = {})
      @name       = name
      @version    = version
      @attributes = ::Mash.new(attributes)
    end

    # @return [Hash]
    def dependencies
      @attributes[:dependencies]
    end

    # @return [Hash]
    def platforms
      @attributes[:platforms]
    end

    # @return [Symbol]
    def location_type
      @attributes[:location_type].to_sym
    end

    # @return [String]
    def location_path
      @attributes[:location_path]
    end

    def to_hash
      {
        name: name,
        version: version,
      }
    end

    def to_json(options = {})
      ::JSON.pretty_generate(to_hash, options)
    end
  end
end
