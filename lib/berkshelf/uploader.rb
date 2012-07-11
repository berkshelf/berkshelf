require 'rest_client'
require 'chef/sandbox'
require 'chef/config'

module Berkshelf
  # @author Jamie Winsor <jamie@vialstudios.com>
  class Uploader
    attr_reader :server_url
    attr_reader :queue

    # @param [String] server_url
    #   the URL to the Chef Server to upload Cookbooks to
    #
    # @option options [String] :node_name
    #   the name of the client used to sign REST requests to the Chef Server
    # 
    #   Default: the value of Chef::Config[:node_name]
    # @option options [String] :client_key
    #   the filepath location for the client's key used to sign REST requests
    #   to the Chef Server
    #
    #   Default: the value of Chef::Config[:client_key]
    def initialize(server_url, options = {})
      options[:node_name] ||= Chef::Config[:node_name]
      options[:client_key] ||= Chef::Config[:client_key]

      @server_url = server_url
      @rest = Chef::REST.new(server_url, options[:node_name], options[:client_key])
      @queue = []
    end

    # Uploads a CachedCookbook from a CookbookStore to this instances Chef Server URL
    #
    # @param [CachedCookbook] cookbook
    #   a cached cookbook to upload
    #
    # @option options [Boolean] :force
    #   Upload the Cookbook even if the version already exists and is frozen on
    #   the target Chef Server
    # @option options [Boolean] :freeze
    #   Freeze the uploaded Cookbook on the Chef Server so that it cannot be
    #   overwritten
    #
    # @return [TXResult]
    def upload(cookbook, options = {})
      upload!(cookbook, options)
    rescue BerkshelfError => e
      TXResult.new(:error, e.message)
    end

    # @see #upload
    def upload!(cookbook, options = {})
      cookbook.validate!

      checksums = cookbook.checksums.dup
      new_sandbox = create_sandbox(checksums)
      upload_checksums_to_sandbox(checksums, new_sandbox)
      commit_sandbox(new_sandbox)
      save_cookbook(cookbook, options)

      TXResult.new(:ok, "#{cookbook.cookbook_name} (#{cookbook.version}) uploaded to: '#{server_url}'")
    end

    private

      attr_reader :rest

      def create_sandbox(checksums)
        massaged_sums = checksums.inject({}) do |memo, elt|
          memo[elt.first] = nil
          memo
        end
        
        rest.post_rest("sandboxes", checksums: massaged_sums)
      end

      def commit_sandbox(sandbox)
        # Retry if S3 is claims a checksum doesn't exist (the eventual
        # in eventual consistency)
        retries = 0
        begin
          rest.put_rest(sandbox['uri'], is_completed: true)
        rescue Net::HTTPServerException => e
          if e.message =~ /^400/ && (retries += 1) <= 5
            sleep 2
            retry
          else
            raise
          end
        end
      end

      def upload_checksums_to_sandbox(checksums, sandbox)
        sandbox['checksums'].each do |checksum, info|
          if info['needs_upload'] == true
            # JW TODO: threads, fibers, or evented uploads here
            upload_file(checksums[checksum], checksum, info['url'])
          end
        end
      end

      def upload_file(file, checksum, url)
        # Checksum is the hexadecimal representation of the md5, but we 
        # need the base64 encoding for the content-md5 header
        checksum64 = Base64.encode64([checksum].pack("H*")).strip
        timestamp = Time.now.utc.iso8601
        file_contents = File.open(file, "rb") {|f| f.read}

        sign_obj = Mixlib::Authentication::SignedHeaderAuth.signing_object(
          http_method: :put,
          path: URI.parse(url).path,
          body: file_contents,
          timestamp: timestamp,
          user_id: rest.client_name
        )
        headers = { 'content-type' => 'application/x-binary', 'content-md5' => checksum64, accept: 'application/json' }
        headers.merge!(sign_obj.sign(OpenSSL::PKey::RSA.new(rest.signing_key)))

        begin
          RestClient::Resource.new(url, headers: headers, timeout: 1800, open_timeout: 1800).put(file_contents)
        rescue RestClient::Exception => e
          raise Berkshelf::UploadFailure, "Failed to upload 'file' to 'url': #{e.message}\n#{e.response.body}"
        end
      end

      def save_cookbook(cookbook, options = {})
        options[:freeze] ||= false
        options[:force] ||= false

        url = "cookbooks/#{cookbook.cookbook_name}/#{cookbook.version}"
        url << "?force=true" if options[:force]

        rest.put_rest(url, cookbook)
      end

      def validate_source(source)
        source.is_a?(Berkshelf::CookbookSource)
      end
  end
end
