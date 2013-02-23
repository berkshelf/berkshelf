module Berkshelf
  # @author Jamie Winsor <reset@riotgames.com>
  class SiteLocation
    extend Forwardable
    include Location

    set_location_key :site

    def_delegator :conn, :api_uri
    attr_accessor :version_constraint

    # @param [#to_s] name
    # @param [Solve::Constraint] version_constraint
    # @param [Hash] options
    #
    # @option options [String, Symbol] :site
    #   a URL pointing to a community API endpoint. Alternatively the symbol :opscode can
    #   be provided to initialize a SiteLocation pointing to the Opscode Community Site.
    def initialize(name, version_constraint, options = {})
      @name               = name
      @version_constraint = version_constraint

      api_uri = if options[:site].nil? || options[:site] == :opscode
        CommunityREST::V1_API
      else
        options[:site]
      end

      @conn = Berkshelf::CommunityREST.new(api_uri)
    end

    # @param [#to_s] destination
    #
    # @return [Berkshelf::CachedCookbook]
    def download(destination)
      version    = target_version
      berks_path = File.join(destination, "#{name}-#{version}")

      temp_path = conn.download(name, version)
      FileUtils.mv(File.join(temp_path, name), berks_path)

      cached = CachedCookbook.from_store_path(berks_path)
      validate_cached(cached)

      set_downloaded_status(true)
      cached
    end

    # Return the latest version that the site location has for the the cookbook
    #
    # @return [String]
    def latest_version
      conn.latest_version(name)
    end

    # Returns a string representing the version of the cookbook that should be downloaded
    # for this location
    #
    # @return [String]
    def target_version
      version = if version_constraint
        conn.satisfy(name, version_constraint)
      else
        latest_version
      end

      if version.nil?
        msg = "Cookbook '#{name}' found at #{self}"
        msg << " that would satisfy constraint (#{version_constraint}" if version_constraint
        raise CookbookNotFound, msg
      end

      version
    end

    def to_hash
      super.merge(value: self.api_uri)
    end

    def to_s
      "#{self.class.location_key}: '#{api_uri}'"
    end

    private

      attr_reader :conn
  end
end
