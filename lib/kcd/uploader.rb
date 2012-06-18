require 'fileutils'
require 'rest_client'
require 'chef/sandbox'

module KnifeCookbookDependencies
  class Uploader
    attr_reader :cookbook_store
    attr_reader :server_url
    attr_reader :queue

    def initialize(cookbook_store, server_url)
      @cookbook_store = cookbook_store
      @server_url = server_url
      @queue = []
    end

    # Uploads the given CookbookSource to the given Chef server url.
    #
    # @params [String] name
    #   name of the Cookbook to upload
    # @params [String] version
    #   version of the Cookbook to upload
    # @param [Hash] options
    #   a hash of options
    #
    #   Options:
    #     force: Upload the Cookbook even if the version already exists and is
    #       frozen on the target Chef Server
    #     freeze: Freeze the uploaded Cookbook on the Chef Server so that it
    #       cannot be overwritten
    #
    # @return [TXResult]
    def upload(name, version, options = {})
      upload!(name, version, options)
    rescue KCDError => e
      TXResult.new(:error, e.message)
    end

    # See #upload. This function will raise if an error occurs.
    def upload!(name, version, options = {})
      cookbook = cookbook_store.cookbook(name, version)
      raise UploadFailure, "Source not downloaded" if cookbook.nil?

      cookbook.validate!

      checksums = cookbook.checksums.dup
      new_sandbox = create_sandbox(checksums)
      upload_checksums_to_sandbox(checksums, new_sandbox)
      commit_sandbox(new_sandbox)
      save_cookbook(cookbook, options)

      TXResult.new(:ok, "#{name} (#{version}) uploaded to: #{server_url}")
    end

    private

      def create_sandbox(checksums)
        massaged_sums = checksums.inject({}) do |memo, elt|
          memo[elt.first] = nil
          memo
        end
        
        rest.post_rest("sandboxes", :checksums => massaged_sums)
      end

      def commit_sandbox(sandbox)
        KCD.ui.debug "Committing sandbox #{sandbox['uri']}"
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
            upload_file(checksums[checksum], checksum, info['url'])
          else
            KCD.ui.debug "#{checksums[checksum]} has not changed"
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
          :http_method => :put,
          :path        => URI.parse(url).path,
          :body        => file_contents,
          :timestamp   => timestamp,
          :user_id     => rest.client_name
        )
        headers = { 'content-type' => 'application/x-binary', 'content-md5' => checksum64, :accept => 'application/json' }
        headers.merge!(sign_obj.sign(OpenSSL::PKey::RSA.new(rest.signing_key)))

        begin
          KCD.ui.debug "Uploading #{file} (checksum hex = #{checksum}) to #{url}"

          RestClient::Resource.new(url, headers: headers, timeout: 1800, open_timeout: 1800).put(file_contents)
        rescue RestClient::Exception => e
          KCD.ui.error "Failed to upload 'cookbook' : #{e.message}\n#{e.response.body}"
          raise
        end
      end

      def save_cookbook(cookbook, options = {})
        options[:freeze] ||= false
        options[:force] ||= false

        url = "cookbooks/#{cookbook.name}/#{cookbook.version}"
        url << "?force=true" if options[:force]

        json = cookbook.to_json
        json['frozen?'] = options[:freeze]

        KCD.ui.debug "Saving cookbook #{cookbook}"
        rest.put_rest(url, json)
      end

      def rest
        @rest ||= Chef::REST.new(server_url)
      end

      def validate_source(source)
        source.is_a?(KCD::CookbookSource)
      end
  end
end
