require 'open-uri'

module Berkshelf
  class RESTAdapter
    #
    # Create a new REST adapter
    #
    # @param [String] base
    #   the base URL to use
    #
    def initialize(base = nil)
      @base = base
    end

    #
    # Get a URL using Ruby's open-uri, capturing any errors.
    #
    # @param [String] segment
    #   the URL segment to fetch
    # @param [Hash] options
    #   options to pass to open-uri
    #
    # @return [Response]
    #
    def get(segment, options = {})
      url = expand(segment)
      io  = open(url, headers.merge(options))

      Response.new(io.status[0], io.read)
    rescue OpenURI::HTTPError => e
      Response.new(e.io.status[0], nil)
    end

    private

      #
      # Calculate the full URL for the given path. If the given path appears
      # to be a full URL on its own, the +base+ URL is not appended.
      # Otherwise, the full URL is calculated from the +base+ given at
      # initialization.
      #
      # @param [String] segment
      #   the URL segment of the path
      #
      # @return [String]
      #
      def expand(segment)
        if segment =~ %r|https?://|
          segment
        else
          File.join(@base, segment)
        end
      end

      #
      # The default headers for any request that comes from Berkshelf.
      #
      # @return [Hash]
      #
      def headers
        {
          'User-Agent' => "Berkshelf/#{Berkshelf::VERSION}",
        }
      end

      #
      # A tiny wrapper around the response from open URI.
      #
      class Response
        # @return [Fixnum]
        attr_reader :status

        # @return [String]
        attr_reader :body

        #
        # @param [String, Fixnum] status
        # @param [String, nil] body
        #
        def initialize(status, body)
          @status = status.to_i
          @body   = body
        end

        #
        # The parsed JSON response.
        #
        # @return [Hash]
        #
        def parsed
          @parsed ||= JSON.parse(@body)
        end
      end
  end
end
