require 'berkshelf/api-client'

module Berkshelf
  class Source
    include Comparable

    # @return [Berkshelf::SourceURI]
    attr_reader :uri

    # @param [String, Berkshelf::SourceURI] uri
    def initialize(uri)
      @uri        = SourceURI.parse(uri)
      @api_client = APIClient.new(uri)
      @universe   = nil
    end

    # Forcefully obtain the universe from the API endpoint and assign it to {#universe}. This
    # will reload the value of {#universe} even if it has been loaded before.
    #
    # @return [Array<APIClient::RemoteCookbook>]
    def build_universe
      @universe = api_client.universe
    rescue => ex
      @universe = Array.new
      raise ex
    end

    # Return the universe from the API endpoint.
    #
    # This is lazily loaded so the universe will be retrieved from the API endpoint on the first
    # call and cached for future calls. Send the {#build_universe} message if you want to reload
    # the cached universe.
    #
    # @return [Array<APIClient::RemoteCookbook>]
    def universe
      @universe || build_universe
    end

    # @param [String] name
    # @param [String] version
    #
    # @return [APIClient::RemoteCookbook]
    def cookbook(name, version)
      universe.find { |cookbook| cookbook.name == name && cookbook.version == version }
    end

    # Determine if this source is a "default" source, as defined in the
    # {Berksfile}.
    #
    # @return [true, false]
    #   true if this a default source, false otherwise
    def default?
      uri.to_s == Berksfile::DEFAULT_API_URL
    end

    # @param [String] name
    #
    # @return [APIClient::RemoteCookbook]
    def latest(name)
      versions(name).sort.last
    end

    # @param [String] name
    #
    # @return [Array<APIClient::RemoteCookbook>]
    def versions(name)
      universe.select { |cookbook| cookbook.name == name }
    end

    def to_s
      "#{uri}"
    end

    def ==(other)
      return false unless other.is_a?(self.class)
      uri == other.uri
    end

    private

      # @return [Berkshelf::APIClient]
      attr_reader :api_client
  end
end
