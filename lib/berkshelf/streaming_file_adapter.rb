require "faraday/adapter/net_http"

module Berkshelf
  class StreamingFileAdapter < Faraday::Adapter::NetHttp
    def call(env)
      env[:streaming_file] = env[:request_headers].delete(:streaming_file) if env[:request_headers] && env[:request_headers][:streaming_file]
      super
    end

    def perform_request(http, env)
      if env[:streaming_file]
        http.request(create_request(env)) do |response|
          response.read_body do |chunk|
            env[:streaming_file].write(chunk) if response.code == "200"
          end
        end
      else
        super
      end
    end
  end
end
