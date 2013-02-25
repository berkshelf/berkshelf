module Berkshelf
  # @author Jamie Winsor <reset@riotgames.com>
  class Uploader
    extend Forwardable

    def_delegator :conn, :client_name
    def_delegator :conn, :client_key
    def_delegator :conn, :organization

    # @option options [String] :server_url
    #   URL to the Chef API
    # @option options [String] :client_name
    #   name of the client used to authenticate with the Chef API
    # @option options [String] :client_key
    #   filepath to the client's private key used to authenticate with
    #   the Chef API
    # @option options [String] :organization
    #   the Organization to connect to. This is only used if you are connecting to
    #   private Chef or hosted Chef
    # @option options [Hash] :params
    #   URI query unencoded key/value pairs
    # @option options [Hash] :headers
    #   unencoded HTTP header key/value pairs
    # @option options [Hash] :request
    #   request options
    # @option options [Hash] :ssl
    #   SSL options
    # @option options [URI, String, Hash] :proxy
    #   URI, String, or Hash of HTTP proxy options
    def initialize(options = {})
      @conn = Ridley.new(options)
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
    # @option options [Boolean] :skip_syntax_check
    #   Skip syntax checking of the Cookbook to reduce the overall upload time 
    #
    # @raise [CookbookNotFound]
    # @raise [CookbookSyntaxError]
    #
    # @return [Boolean]
    def upload(cookbook, options = {})
      cookbook.validate! unless options[:skip_syntax_check]
      checksums = cookbook.checksums.dup
      sandbox   = conn.sandbox.create(checksums.keys)

      sandbox.upload(checksums)
      sandbox.commit

      conn.cookbook.save(
        cookbook.cookbook_name,
        cookbook.version,
        cookbook.to_json,
        options
      )
    end

    private

      attr_reader :conn
  end
end
