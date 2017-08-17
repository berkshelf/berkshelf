require "set"
require "berkshelf/mixin/logging"

module Berkshelf
  module Middleware
    # Borrowed and modified from:
    # {https://github.com/lostisland/faraday_middleware/blob/master/lib/faraday_middleware/response/follow_redirects.rb}
    #
    # Public: Follow HTTP 301, 302, 303, and 307 redirects for GET, PATCH, POST,
    # PUT, and DELETE requests.
    #
    # This middleware does not follow the HTTP specification for HTTP 302, by
    # default, in that it follows the improper implementation used by most major
    # web browsers which forces the redirected request to become a GET request
    # regardless of the original request method.
    #
    # For HTTP 301, 302, and 303, the original request is transformed into a
    # GET request to the response Location, by default. However, with standards
    # compliance enabled, a 302 will instead act in accordance with the HTTP
    # specification, which will replay the original request to the received
    # Location, just as with a 307.
    #
    # For HTTP 307, the original request is replayed to the response Location,
    # including original HTTP request method (GET, POST, PUT, DELETE, PATCH),
    # original headers, and original body.
    #
    # This middleware currently only works with synchronous requests; in other
    # words, it doesn't support parallelism.
    class FollowRedirects < Faraday::Middleware
      include Berkshelf::Mixin::Logging
      # HTTP methods for which 30x redirects can be followed
      ALLOWED_METHODS = Set.new [:head, :options, :get, :post, :put, :patch, :delete]
      # HTTP redirect status codes that this middleware implements
      REDIRECT_CODES  = Set.new [301, 302, 303, 307]
      # Keys in env hash which will get cleared between requests
      ENV_TO_CLEAR    = Set.new [:status, :response, :response_headers]

      # Default value for max redirects followed
      FOLLOW_LIMIT = 3

      # Public: Initialize the middleware.
      #
      # options - An options Hash (default: {}):
      #           limit - A Numeric redirect limit (default: 3)
      #           standards_compliant - A Boolean indicating whether to respect
      #                                 the HTTP spec when following 302
      #                                 (default: false)
      #          cookie - Use either an array of strings
      #                  (e.g. ['cookie1', 'cookie2']) to choose kept cookies
      #                  or :all to keep all cookies.
      def initialize(app, options = {})
        super(app)
        @options = options

        @replay_request_codes = Set.new [307]
        @replay_request_codes << 302 if standards_compliant?
      end

      def call(env)
        perform_with_redirection(env, follow_limit)
      end

      private

      def perform_with_redirection(env, follows)
        request_body = env[:body]
        response = @app.call(env)

        response.on_complete do |env|
          if follow_redirect?(env, response)
            log.debug { "==> request redirected to #{response['location']}" }
            log.debug { "request env: #{env}" }

            if follows == 0
              log.debug { "==> too many redirects" }
              raise Berkshelf::Errors::RedirectLimitReached, response
            end

            env = update_env(env, request_body, response)
            response = perform_with_redirection(env, follows - 1)
          end
        end
        response
      end

      def update_env(env, request_body, response)
        env[:url] += response["location"]
        if @options[:cookies]
          cookies = keep_cookies(env)
          env[:request_headers][:cookies] = cookies unless cookies.nil?
        end

        env[:body] = request_body

        ENV_TO_CLEAR.each { |key| env.delete key }

        env
      end

      def follow_redirect?(env, response)
        ALLOWED_METHODS.include?(env[:method]) &&
          REDIRECT_CODES.include?(response.status)
      end

      def follow_limit
        @options.fetch(:limit, FOLLOW_LIMIT)
      end

      def keep_cookies(env)
        cookies = @options.fetch(:cookies, [])
        response_cookies = env[:response_headers][:cookies]
        cookies == :all ? response_cookies : selected_request_cookies(response_cookies)
      end

      def selected_request_cookies(cookies)
        selected_cookies(cookies)[0...-1]
      end

      def selected_cookies(cookies)
        "".tap do |cookie_string|
          @options[:cookies].each do |cookie|
            string = /#{cookie}=?[^;]*/.match(cookies)[0] + ";"
            cookie_string << string
          end
        end
      end

      def standards_compliant?
        @options.fetch(:standards_compliant, false)
      end
    end
  end
end

Faraday::Response.register_middleware follow_redirects: Berkshelf::Middleware::FollowRedirects
