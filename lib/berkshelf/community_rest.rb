require 'open-uri'
require 'retryable'
require 'addressable/uri'

module Berkshelf
  class CommunityREST < Faraday::Connection
    class << self
      # @param [String] target
      #   file path to the tar.gz archive on disk
      # @param [String] destination
      #   file path to extract the contents of the target to
      #
      # @return [String]
      def unpack(target, destination = Dir.mktmpdir)
        if is_gzip_file(target)
          Archive::Tar::Minitar.unpack(Zlib::GzipReader.new(File.open(target, 'rb')), destination)
        elsif is_tar_file(target)
          Archive::Tar::Minitar.unpack(target, destination)
        elsif is_bzip2_file(target)
          Archive::Tar::Minitar.unpack(RBzip2::Decompressor.new(File.open(target, 'rb')), destination)
        else
          raise Berkshelf::UnknownCompressionType.new(target)
        end
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

        def is_bzip2_file(path)
          IO.binread(path, 3) == 'BZh'
        end
    end

    V1_API = 'http://cookbooks.opscode.com/api/v1/cookbooks'.freeze

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
      options         = options.reverse_merge(retries: 5, retry_interval: 0.5)
      @api_uri        = Addressable::URI.parse(uri)
      @retries        = options[:retries]
      @retry_interval = options[:retry_interval]

      builder = Faraday::Builder.new do |b|
        b.response :parse_json
        b.request :retry,
          max: @retries,
          interval: @retry_interval,
          exceptions: [Faraday::Error::TimeoutError]

        b.adapter :net_http
      end

      super(api_uri, builder: builder)
    end

    # @param [String] name
    # @param [String] version
    #
    # @return [String]
    def download(name, version)
      archive = stream(find(name, version)[:file])
      self.class.unpack(archive.path)
    ensure
      archive.unlink unless archive.nil?
    end

    def find(name, version)
      response = get("#{name}/versions/#{self.class.uri_escape_version(version)}")

      case response.status
      when (200..299)
        response.body
      when 404
        raise CookbookNotFound, "Cookbook '#{name}' not found at site: '#{api_uri}'"
      else
        raise CommunitySiteError, "Error finding cookbook '#{name}' (#{version}) at site: '#{api_uri}'"
      end
    end

    # Returns the latest version of the cookbook and it's download link.
    #
    # @return [String]
    def latest_version(name)
      response = get(name)

      case response.status
      when (200..299)
        self.class.version_from_uri response.body['latest_version']
      when 404
        raise CookbookNotFound, "Cookbook '#{name}' not found at site: '#{api_uri}'"
      else
        raise CommunitySiteError, "Error retrieving latest version of cookbook '#{name}' at site: '#{api_uri}'"
      end
    end

    # @param [String] name
    #
    # @return [Array]
    def versions(name)
      response = get(name)

      case response.status
      when (200..299)
        response.body['versions'].collect do |version_uri|
          self.class.version_from_uri(version_uri)
        end
      when 404
        raise CookbookNotFound, "Cookbook '#{name}' not found at site: '#{api_uri}'"
      else
        raise CommunitySiteError, "Error retrieving versions of cookbook '#{name}' at site: '#{api_uri}'"
      end
    end

    # @param [String] name
    # @param [String, Solve::Constraint] constraint
    #
    # @return [String]
    def satisfy(name, constraint)
      Solve::Solver.satisfy_best(constraint, versions(name)).to_s
    rescue Solve::Errors::NoSolutionError
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

      retryable(tries: retries, on: OpenURI::HTTPError, sleep: retry_interval) do
        open(target, 'rb', headers) do |remote|
          local.write(remote.read)
        end
      end

      local
    ensure
      local.close(false) unless local.nil?
    end
  end
end
