require "chef/server_api"
require "chef/http/simple_json"
require "chef/http/simple"
require "berkshelf/api_client/errors"
require "chef/config"

module Berkshelf
  module RidleyCompatAPI
    def initialize(**opts)
      opts = opts.dup
      opts[:ssl] ||= {}
      chef_opts = {}
      chef_opts[:rest_timeout]         = opts[:timeout] if opts[:timeout] # opts[:open_timeout] is ignored on purpose
      chef_opts[:headers]              = opts[:headers] if opts[:headers]
      chef_opts[:client_name]          = opts[:client_name] if opts[:client_name]
      chef_opts[:signing_key_filename] = opts[:client_key] if opts[:client_key]
      chef_opts[:verify_api_cert]      = opts[:ssl][:verify] || opts[:ssl][:verify].nil?
      chef_opts[:ssl_verify_mode]      = chef_opts[:verify_api_cert] ? :verify_peer : :verify_none
      chef_opts[:ssl_ca_path]          = opts[:ssl][:ca_path] if opts[:ssl][:ca_path]
      chef_opts[:ssl_ca_file]          = opts[:ssl][:ca_file] if opts[:ssl][:ca_file]
      chef_opts[:ssl_client_cert]      = opts[:ssl][:client_cert] if opts[:ssl][:client_cert]
      chef_opts[:ssl_client_key]       = opts[:ssl][:client_key] if opts[:ssl][:client_key]
      # chef/http/ssl_policies.rb reads only from Chef::Config and not from the opts in the constructor
      Chef::Config[:verify_api_cert] = chef_opts[:verify_api_cert]
      Chef::Config[:ssl_verify_mode] = chef_opts[:ssl_verify_mode]
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
