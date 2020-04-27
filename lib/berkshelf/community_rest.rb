require "retryable"
require "mixlib/archive"

module Berkshelf
  class CommunityREST
    class << self
      # @param [String] target
      #   file path to the tar.gz archive on disk
      # @param [String] destination
      #   file path to extract the contents of the target to
      #
      # @return [String]
      def unpack(target, destination)
        if is_gzip_file(target) || is_tar_file(target)
          Mixlib::Archive.new(target).extract(destination)
        else
          raise Berkshelf::UnknownCompressionType.new(target, destination)
        end

        destination
      end

      # @param [String] version
      #
      # @return [String]
      def uri_escape_version(version)
        version.to_s.tr(".", "_")
      end

      # @param [String] uri
      #
      # @return [String]
      def version_from_uri(uri)
        File.basename(uri.to_s).tr("_", ".")
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

    V1_API = "https://supermarket.chef.io".freeze

    # @return [String]
    attr_reader :api_uri
    # @return [Integer]
    #   how many retries to attempt on HTTP requests
    attr_reader :retries
    # @return [Float]
    #   time to wait between retries
    attr_reader :retry_interval
    # @return [Berkshelf::RidleyCompat]
    attr_reader :connection

    # @param [String] uri (CommunityREST::V1_API)
    #   location of community site to connect to
    #
    # @option options [Integer] :retries (5)
    #   retry requests on 5XX failures
    # @option options [Float] :retry_interval (0.5)
    #   how often we should pause between retries
    def initialize(uri = V1_API, options = {})
      options = options.dup
      options = { retries: 5, retry_interval: 0.5, ssl: Berkshelf::Config.instance.ssl }.merge(options)
      @api_uri = uri
      options[:server_url] = uri
      @retries = options.delete(:retries)
      @retry_interval = options.delete(:retry_interval)

      @connection = Berkshelf::RidleyCompatJSON.new(**options)
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
      archive = stream(find(name, version)["file"])
      scratch = Dir.mktmpdir
      extracted = self.class.unpack(archive.path, scratch)

      if File.cookbook?(extracted)
        extracted
      else
        Dir.glob("#{extracted}/*").find do |dir|
          File.cookbook?(dir)
        end
      end
    ensure
      archive.unlink unless archive.nil?
    end

    def find(name, version)
      body = connection.get("cookbooks/#{name}/versions/#{self.class.uri_escape_version(version)}")

      # Artifactory responds with a 200 and blank body for unknown cookbooks.
      raise CookbookNotFound.new(name, nil, "at `#{api_uri}'") if body.nil?

      body
    rescue CookbookNotFound
      raise
    rescue Berkshelf::APIClient::ServiceNotFound
      raise CookbookNotFound.new(name, nil, "at `#{api_uri}'")
    rescue
      raise CommunitySiteError.new(api_uri, "'#{name}' (#{version})")
    end

    # Returns the latest version of the cookbook and its download link.
    #
    # @return [String]
    def latest_version(name)
      body = connection.get("cookbooks/#{name}")

      # Artifactory responds with a 200 and blank body for unknown cookbooks.
      raise CookbookNotFound.new(name, nil, "at `#{api_uri}'") if body.nil?

      self.class.version_from_uri body["latest_version"]
    rescue Berkshelf::APIClient::ServiceNotFound
      raise CookbookNotFound.new(name, nil, "at `#{api_uri}'")
    rescue
      raise CommunitySiteError.new(api_uri, "the latest version of '#{name}'")
    end

    # @param [String] name
    #
    # @return [Array]
    def versions(name)
      body = connection.get("cookbooks/#{name}")

      # Artifactory responds with a 200 and blank body for unknown cookbooks.
      raise CookbookNotFound.new(name, nil, "at `#{api_uri}'") if body.nil?

      body["versions"].collect do |version_uri|
        self.class.version_from_uri(version_uri)
      end

    rescue Berkshelf::APIClient::ServiceNotFound
      raise CookbookNotFound.new(name, nil, "at `#{api_uri}'")
    rescue
      raise CommunitySiteError.new(api_uri, "versions of '#{name}'")
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
      local = Tempfile.new("community-rest-stream")
      local.binmode
      Retryable.retryable(tries: retries, on: Berkshelf::APIClientError, sleep: retry_interval) do
        connection.streaming_request(target, {}, local)
      end
    ensure
      local.close(false) unless local.nil?
    end
  end
end
