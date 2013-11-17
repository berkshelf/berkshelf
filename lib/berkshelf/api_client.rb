require_relative 'rest_adapter'

module Berkshelf
  #
  # A class for communicating with a hosted Berkshelf API Server.
  #
  # @example
  #   client = Berkshelf::APIClient.new('https://api.berkshelf.com')
  #   client.universe #=> [#<RemoteCookbook @name="berkshelf">, ...]
  #
  class APIClient < RESTAdapter
    require_relative 'api_client/remote_cookbook'

    class BadResponse < BerkshelfError
      def initialize(url)
        super \
          "Berkshelf received an unexpected response from an API server. " \
          "Please make sure the API server is accessible and running at " \
          "#{url.inspect}." \
          "\n\n" \
          "If this is an internally run API server, try accessing it from " \
          "your web browser. If this is a public API server, please check " \
          "the status website or #berkshelf on freenode for outage " \
          "information."
      end
    end

    #
    # Retrieves the entire universe of known cookbooks from the API source.
    #
    # @return [Array<APIClient::RemoteCookbook>]
    #
    def universe
      response = get('universe')

      case response.status
      when (200..299)
        response.parsed.collect do |name, versions|
          versions.collect do |version, attributes|
            RemoteCookbook.new(name, version, attributes)
          end
        end.flatten
      else
        raise BadResponse.new(@base)
      end
    end
  end
end
