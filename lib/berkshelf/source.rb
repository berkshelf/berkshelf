module Berkshelf
  class Source
    # @return [Berkshelf::SourceURI]
    attr_reader :uri

    # @param [String, Berkshelf::SourceURI] uri
    def initialize(uri)
      @uri        = SourceURI.parse(uri)
      @api_client = APIClient.new(uri)
    end

    # @return [Hash]
    def universe
      @universe ||= api_client.universe
    end

    # @param [String] name
    # @param [String] version
    def cookbook(name, version)
      universe.find { |cookbook| cookbook.name == name && cookbook.version == version }
    end

    # @param [String] name
    def versions(name)
      universe.select { |cookbook| cookbook.name == name }
    end

    private

      # @return [Berkshelf::APIClient]
      attr_reader :api_client
  end
end
