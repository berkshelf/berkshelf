require 'addressable/uri'

module Berkshelf
  class APIClient < Faraday::Connection
    require_relative 'api_client/remote_cookbook'

    # @return [Addressable::URI]
    attr_reader :url
    # @return [Integer]
    #   how many retries to attempt on HTTP requests
    attr_reader :retries
    # @return [Float]
    #   time to wait between retries
    attr_reader :retry_interval

    def initialize(url, options = {})
      options         = options.reverse_merge(retries: 5, retry_interval: 0.5)
      @url            = Addressable::URI.parse(url)
      @retries        = options[:retries]
      @retry_interval = options[:retry_interval]

      builder = Faraday::Builder.new do |b|
        b.response :parse_json
        b.response :gzip
        b.request :retry,
          max: @retries,
          interval: @retry_interval,
          exceptions: [ Faraday::Error::TimeoutError ]

        b.adapter :net_http
      end

      super(@url, builder: builder)
    end

    def universe
      response = get("universe")

      case response.status
      when 200
        [].tap do |cookbooks|
          response.body.each do |name, versions|
            versions.each { |version, attributes| cookbooks << RemoteCookbook.new(name, version, attributes) }
          end
        end
      else
        raise RuntimeError, "bad response #{response.inspect}"
      end
    end
  end
end
