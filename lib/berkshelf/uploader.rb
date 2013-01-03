require 'chef/cookbook_uploader'
require 'chef/knife/cookbook_upload'
module Berkshelf
  # @author Jamie Winsor <jamie@vialstudios.com>
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
    #  @conn = Ridley.connection(options)
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
      loader = Chef::Cookbook::CookbookVersionLoader.new(cookbook.path)
      loader.load_cookbooks
      cv = loader.cookbook_version
      cv.send(:generate_manifest)
      cv.name = cookbook.cookbook_name.to_sym
      cv.manifest['name'] = "#{cookbook.cookbook_name}-#{cookbook.version}" #.sub!(%r{-[^-]+$}, '')
      cv.manifest['cookbook_name'] = cookbook.cookbook_name
      Chef::CookbookUploader.new([cv], cookbook.path).upload_cookbooks
    end

    private

      attr_reader :conn
  end
end
