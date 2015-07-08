require 'open-uri'
require 'retryable'

module Berkshelf
  class CommunityREST < Faraday::Connection
    class << self
      # @param [String] target
      #   file path to the tar.gz archive on disk
      # @param [String] destination
      #   file path to extract the contents of the target to
      #
      # @return [String]
      def unpack(target, destination)
        if is_gzip_file(target)
          Archive::Tar::Minitar.unpack(Zlib::GzipReader.new(File.open(target, 'rb')), destination)
        elsif is_tar_file(target)
          Archive::Tar::Minitar.unpack(target, destination)
        else
          raise Berkshelf::UnknownCompressionType.new(target, destination)
        end

        FileUtils.rm_rf Dir.glob("#{destination}/**/PaxHeader")
        destination
      end

      # @param [String] version
      #
      # @return [String]
      def uri_escape_version(version)
        version.to_s.gsub('.', '_')
      end

      # @param [String] uri
      #
      # @return [String]
      def version_from_uri(uri)
        File.basename(uri.to_s).gsub('_', '.')
      end

      private

        def is_gzip_file(path)
          # You cannot write "\x1F\x8B" because the default encoding of
          # ruby >= 1.9.3 is UTF-8 and 8B is an invalid in UTF-8.
          IO.binread(path, 2) == [0x1F, 0x8B].pack("C*")
        end

        def is_tar_file(path)
          IO.binread(path, 8, 257).to_s == "ustar\x0000"
        end
    end

    V1_API = 'https://supermarket.chef.io'.freeze

    # @return [String]
    attr_reader :api_uri
    # @return [Integer]
    #   how many retries to attempt on HTTP requests
    attr_reader :retries
    # @return [Float]
    #   time to wait between retries
    attr_reader :retry_interval

    # @param [String] uri (CommunityREST::V1_API)
    #   location of community site to connect to
    #
    # @option options [Integer] :retries (5)
    #   retry requests on 5XX failures
    # @option options [Float] :retry_interval (0.5)
    #   how often we should pause between retries
    def initialize(uri = V1_API, options = {})
      options         = options.reverse_merge(retries: 5, retry_interval: 0.5, ssl: { verify: Berkshelf::Config.instance.ssl.verify })
      @api_uri        = uri
      @retries        = options.delete(:retries)
      @retry_interval = options.delete(:retry_interval)

      options[:builder] ||= Faraday::RackBuilder.new do |b|
        b.response :parse_json
        b.response :follow_redirects
        b.request :retry,
          max: @retries,
          interval: @retry_interval,
          exceptions: [Faraday::Error::TimeoutError]

        b.adapter :httpclient
      end

      super(api_uri, options)
    end

    # Download and extract target cookbook archive to the local file system,
    # returning its filepath.
    #
    # @param [String] name
    #   the name of the cookbook
    # @param [String] version
    #   the targeted version of the cookbook
    #
    # @return [String, nil]
    #   cookbook filepath, or nil if archive does not contain a cookbook
    def download(name, version)
      archive   = stream(find(name, version)[:file])
      scratch = Dir.mktmpdir
      extracted = self.class.unpack(archive.path, scratch)

      if File.cookbook?(extracted)
        extracted
      else
        Dir.glob(File.join(extracted, '*')).find do |dir|
          File.cookbook?(dir)
        end
      end
    ensure
      archive.unlink unless archive.nil?
    end

    def find(name, version)
      response = get("cookbooks/#{name}/versions/#{self.class.uri_escape_version(version)}")

      case response.status
      when (200..299)
        response.body
      when 404
        raise CookbookNotFound.new(name, nil, "at `#{api_uri}'")
      else
        raise CommunitySiteError.new(api_uri, "'#{name}' (#{version})")
      end
    end

    # Returns the latest version of the cookbook and its download link.
    #
    # @return [String]
    def latest_version(name)
      response = get("cookbooks/#{name}")

      case response.status
      when (200..299)
        self.class.version_from_uri response.body['latest_version']
      when 404
        raise CookbookNotFound.new(name, nil, "at `#{api_uri}'")
      else
        raise CommunitySiteError.new(api_uri, "the latest version of '#{name}'")
      end
    end

    # @param [String] name
    #
    # @return [Array]
    def versions(name)
      response = get("cookbooks/#{name}")

      case response.status
      when (200..299)
        response.body['versions'].collect do |version_uri|
          self.class.version_from_uri(version_uri)
        end
      when 404
        raise CookbookNotFound.new(name, nil, "at `#{api_uri}'")
      else
        raise CommunitySiteError.new(api_uri, "versions of '#{name}'")
      end
    end

    # @param [String] name
    # @param [String, Semverse::Constraint] constraint
    #
    # @return [String]
    def satisfy(name, constraint)
      Semverse::Constraint.satisfy_best(constraint, versions(name)).to_s
    rescue Semverse::NoSolutionError
      nil
    end

    # Stream the response body of a remote URL to a file on the local file system
    #
    # @param [String] target
    #   a URL to stream the response body from
    #
    # @return [Tempfile]
    def stream(target)
      local = Tempfile.new('community-rest-stream')
      local.binmode

      Retryable.retryable(tries: retries, on: OpenURI::HTTPError, sleep: retry_interval) do
        open(target, 'rb', open_uri_options) do |remote|
          local.write(remote.read)
        end
      end

      local
    ensure
      local.close(false) unless local.nil?
    end

    private

      def open_uri_options
        options = {}
        options.merge!(headers)
        options.merge!(open_uri_proxy_options)
		    options.merge!(ssl_verify_mode: ssl_verify_mode)
      end

      def open_uri_proxy_options
        if proxy && proxy[:user] && proxy[:password]
          {proxy_http_basic_authentication: [ proxy[:uri], proxy[:user], proxy[:password] ]}
        else
          {}
        end
      end

      def ssl_verify_mode
        if Berkshelf::Config.instance.ssl.verify.nil? || Berkshelf::Config.instance.ssl.verify
          OpenSSL::SSL::VERIFY_PEER
        else
          OpenSSL::SSL::VERIFY_NONE
        end
      end
  end
end
