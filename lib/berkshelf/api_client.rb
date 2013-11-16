module Berkshelf
  # Used to communicate with a remotely hosted [Berkshelf API Server](https://github.com/riotgames/berkshelf-api).
  #
  # @example
  #   client = Berkshelf::APIClient.new("https://api.berkshelf.com")
  #   client.universe #=> [...]
  class APIClient < Faraday::Connection
    autoload :RemoteCookbook, 'berkshelf/api_client/remote_cookbook'

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
    # @option options [Integer] :retries
    #   how many retries to perform before giving up
    # @option options [Float] :retry_interval
    #   how long to wait (in seconds) between each retry
    def initialize(url, options = {})
      options         = options.reverse_merge(retries: 5, retry_interval: 0.5)
      @url            = url
      @retries        = options[:retries]
      @retry_interval = options[:retry_interval]

      options[:builder] ||= Faraday::Builder.new do |b|
        b.response :parse_json
        b.response :gzip
        b.request :retry,
          max: self.retries,
          interval: self.retry_interval,
          exceptions: [ Faraday::Error::TimeoutError ]

        b.adapter :net_http
      end

      super(self.url, options)
    end

    # Retrieves the entire universe of known cookbooks from the API source
    #
    # @return [Array<APIClient::RemoteCookbook>]
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
