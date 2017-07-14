require "berkshelf/ridley_compat"

module Berkshelf::APIClient
  require_relative "errors"

  class Connection
    # @return [String]
    attr_reader :url

    # @return [Integer]
    #   how many retries to attempt on HTTP requests
    attr_reader :retries

    # @return [Float]
    #   time to wait between retries
    attr_reader :retry_interval

    # @param [String, Addressable::URI] url
    #
    # @option options [Integer] :open_timeout (3)
    #   how long to wait (in seconds) for connection open to the API server
    # @option options [Integer] :timeout (30)
    #   how long to wait (in seconds) before getting a response from the API server
    # @option options [Integer] :retries (3)
    #   how many retries to perform before giving up
    # @option options [Float] :retry_interval (0.5)
    #   how long to wait (in seconds) between each retry
    def initialize(url, options = {})
      # it looks like Faraday mutates the URI argument it is given, when we ripped Faraday out of this
      # API it stopped doing that.  this may or may not be a breaking change (it broke some fairly
      # brittle berkshelf tests).  if it causes too much berkshelf chaos we could revert by uncommenting
      # the next line.  as it is removing this behavior feels more like fixing a bug.
      #@url = url.normalize! if url.is_a?(Addressable::URI)
      options = { retries: 3, retry_interval: 0.5, open_timeout: 30, timeout: 30 }.merge(options)
      options[:server_url] = url

      @client = Berkshelf::RidleyCompatJSON.new(**options)
    end

    # Retrieves the entire universe of known cookbooks from the API source
    #
    # @raise [APIClient::TimeoutError]
    #
    # @return [Array<APIClient::RemoteCookbook>]
    def universe
      response = @client.get("universe")

      [].tap do |cookbooks|
        response.each do |name, versions|
          versions.each { |version, attributes| cookbooks << RemoteCookbook.new(name, version, attributes) }
        end
      end
    end
  end
end
