require 'chef/server_api'
require 'chef/http/simple_json'
require 'chef/http/simple'
require 'berkshelf/api_client/errors'

module Berkshelf
  module RidleyCompatAPI
    def initialize(**opts)
      opts = opts.dup
      opts[:ssl] ||= {}
      chef_opts = {
        rest_timeout: opts[:timeout], # opts[:open_timeout] is ignored on purpose
        headers: opts[:headers],
        client_name: opts[:client_name],
        signing_key_filename: opts[:client_key],
        ssl_verify_mode: opts[:verify] ? :verify_none : :verify_peer,
        ssl_ca_path: opts[:ssl][:ca_path],
        ssl_ca_file: opts[:ssl][:ca_file],
        ssl_client_cert: opts[:ssl][:client_cert],
        ssl_client_key: opts[:ssl][:client_key],
      }
      super(opts[:server_url].to_s, **chef_opts)
    end

    def get(url)
      super(url)
    rescue Net::HTTPExceptions => e
      case e.response.code
      when "404"
        raise Berkshelf::APIClient::ServiceNotFound, "service not found at: #{url}"
      when /^5/
        raise Berkshelf::APIClient::ServiceUnavailable, "service unavailable at: #{url}"
      else
        raise Berkshelf::APIClient::BadResponse, "bad response #{e.response}"
      end
    rescue Errno::ETIMEDOUT, Timeout::Error
      raise Berkshelf::APIClient::TimeoutError, "Unable to connect to: #{url}"
    rescue Errno::EHOSTUNREACH, Errno::ECONNREFUSED => e
      raise Berkshelf::APIClient::ServiceUnavailable, e
    end
  end

  # This is for simple HTTP
  class RidleyCompatSimple < Chef::ServerAPI
    use Chef::HTTP::Decompressor
    use Chef::HTTP::CookieManager
    use Chef::HTTP::ValidateContentLength

    include RidleyCompatAPI
  end

  # This is for JSON-REST
  class RidleyCompatJSON < Chef::HTTP::SimpleJSON
    use Chef::HTTP::JSONInput
    use Chef::HTTP::JSONOutput
    use Chef::HTTP::CookieManager
    use Chef::HTTP::Decompressor
    use Chef::HTTP::RemoteRequestID
    use Chef::HTTP::ValidateContentLength

    include RidleyCompatAPI
  end

  # RidleyCompat is the ServerAPI, but we inherit from Chef::HTTP::Simple and then include all our middlewares
  # and then need to include our own CompatAPI.  The end result is a ridley-esque way of talking to a chef server.
  class RidleyCompat < Chef::HTTP::Simple
    use Chef::HTTP::JSONInput
    use Chef::HTTP::JSONOutput
    use Chef::HTTP::CookieManager
    use Chef::HTTP::Decompressor
    use Chef::HTTP::Authenticator
    use Chef::HTTP::RemoteRequestID
    use Chef::HTTP::APIVersions if defined?(Chef::HTTP::APIVersions)
    use Chef::HTTP::ValidateContentLength

    include RidleyCompatAPI
  end
end
