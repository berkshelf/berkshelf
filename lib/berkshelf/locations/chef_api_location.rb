module Berkshelf
  # @author Jamie Winsor <reset@riotgames.com>
  class ChefAPILocation
    class << self
      # @param [String] node_name
      #
      # @return [Boolean]
      def validate_node_name(node_name)
        node_name.is_a?(String) && !node_name.empty?
      end

      # @raise [InvalidChefAPILocation]
      #
      # @see validate_node_name
      def validate_node_name!(node_name)
        unless validate_node_name(node_name)
          raise InvalidChefAPILocation
        end

        true
      end

      # @param [String] client_key
      #
      # @return [Boolean]
      def validate_client_key(client_key)
        File.exists?(client_key)
      end

      # @raise [InvalidChefAPILocation]
      #
      # @see validate_client_key
      def validate_client_key!(client_key)
        unless validate_client_key(client_key)
          raise InvalidChefAPILocation
        end

        true
      end

      # @param [String] uri
      #
      # @return [Boolean]
      def validate_uri(uri)
        uri =~ URI.regexp(['http', 'https'])
      end

      # @raise [InvalidChefAPILocation] if the given object is not a String containing a
      #   valid Chef API URI
      #
      # @see validate_uri
      def validate_uri!(uri)
        unless validate_uri(uri)
          raise InvalidChefAPILocation, "'#{uri}' is not a valid Chef API URI."
        end

        true
      end
    end

    include Location

    set_location_key :chef_api
    set_valid_options :node_name, :client_key

    attr_reader :uri
    attr_reader :node_name
    attr_reader :client_key

    # @param [#to_s] name
    # @param [Solve::Constraint] version_constraint
    # @param [Hash] options
    #
    # @option options [String, Symbol] :chef_api
    #   a URL to a Chef API. Alternatively the symbol :config can be provided
    #   which will instantiate this location with the values found in your
    #   Berkshelf configuration.
    # @option options [String] :node_name
    #   the name of the client to use to communicate with the Chef API.
    #   Default: Chef::Config[:node_name]
    # @option options [String] :client_key
    #   the filepath to the authentication key for the client
    #   Default: Chef::Config[:client_key]
    def initialize(name, version_constraint, options = {})
      @name               = name
      @version_constraint = version_constraint
      @downloaded_status  = false

      if options[:chef_api] == :knife
        Berkshelf.formatter.deprecation "specifying 'chef_api :knife' is deprecated. Please use 'chef_api :config'."
        options[:chef_api] = :config
      end

      validate_options!(options)

      if options[:chef_api] == :config
        unless Berkshelf::Config.instance.chef.node_name.present? &&
          Berkshelf::Config.instance.chef.client_key.present? &&
          Berkshelf::Config.instance.chef.chef_server_url.present?
          raise ConfigurationError, "A Berkshelf configuration is required with a 'chef.client_key', 'chef.chef_server_Url', and 'chef.node_name' setting to install or upload cookbooks using 'chef_api :config'."
        end
        @node_name  = Berkshelf::Config.instance.chef.node_name
        @client_key = Berkshelf::Config.instance.chef.client_key
        @uri        = Berkshelf::Config.instance.chef.chef_server_url
      else
        @node_name  = options[:node_name]
        @client_key = options[:client_key]
        @uri        = options[:chef_api]
      end

      @rest = ::Chef::REST.new(uri, node_name, client_key)
    end

    # @param [#to_s] destination
    #
    # @return [Berkshelf::CachedCookbook]
    def download(destination)
      version, uri = target_version
      scratch = download_files(download_manifest(uri))

      cb_path = File.join(destination, "#{name}-#{version}")
      FileUtils.mv(scratch, cb_path)

      cached = CachedCookbook.from_store_path(cb_path)
      validate_cached(cached)

      set_downloaded_status(true)
      cached
    end

    # Returns a hash representing the cookbook versions on at a Chef API for location's cookbook.
    # The keys are version strings and the values are URLs to download the cookbook version.
    #
    # @example
    #   {
    #     "0.101.2" => "https://api.opscode.com/organizations/vialstudios/cookbooks/nginx/0.101.2",
    #     "0.101.5" => "https://api.opscode.com/organizations/vialstudios/cookbooks/nginx/0.101.5"
    #   }
    #
    # @return [Hash]
    def versions
      {}.tap do |versions|
        rest.get_rest("cookbooks/#{name}").each do |name, data|
          data["versions"].each do |version_info|
            versions[version_info["version"]] = version_info["url"]
          end
        end
      end
    rescue Net::HTTPServerException => e
      if e.response.code == "404"
        raise CookbookNotFound, "Cookbook '#{name}' not found at chef_api: '#{uri}'"
      else
        raise
      end
    end

    # Returns an array where the first element is a string representing the latest version of
    # the Cookbook and the second element is the download URL for that version.
    #
    # @example
    #   [ "0.101.2" => "https://api.opscode.com/organizations/vialstudios/cookbooks/nginx/0.101.2" ]
    #
    # @return [Array]
    def latest_version
      graph = Solve::Graph.new
      versions.each do |version, url|
        graph.artifacts(name, version)
      end

      version = Solve.it!(graph, [name])[name]

      [ version, versions[version] ]
    end

    def to_hash
      super.merge(value: self.uri)
    end

    def to_s
      "#{self.class.location_key}: '#{uri}'"
    end

    private

      attr_reader :rest

      # Retrieve a cookbooks manifest from the given URL
      #
      # @param [String] uri
      #
      # @return [Hash]
      def download_manifest(uri)
        ::Chef::CookbookVersion.json_create(rest.get_rest(uri)).manifest
      end

      # Returns an array containing the version and download URL for the cookbook version that
      # should be downloaded for this location.
      #
      # @example
      #   [ "0.101.2" => "https://api.opscode.com/organizations/vialstudios/cookbooks/nginx/0.101.2" ]
      #
      # @return [Array]
      def target_version
        if version_constraint
          solution = self.class.solve_for_constraint(version_constraint, versions)

          unless solution
            raise NoSolution, "No cookbook version of '#{name}' found at #{self} that would satisfy constraint (#{version_constraint})."
          end

          solution
        else
          latest_version
        end
      end

      # Download all of the files in the given manifest to the given destination. If no destination
      # is provided a temporary directory will be created and the files will be downloaded to there.
      #
      # @note
      #   the manifest Hash is the same manifest that you get by sending the manifest message to
      #   an instance of Chef::CookbookVersion.
      #
      # @param [Hash] manifest
      # @param [String] destination
      #
      # @return [String]
      #   the path to the directory containing the files
      def download_files(manifest, destination = Dir.mktmpdir)
        ::Chef::CookbookVersion::COOKBOOK_SEGMENTS.each do |segment|
          next unless manifest.has_key?(segment)
          manifest[segment].each do |segment_file|
            dest = File.join(destination, segment_file['path'].gsub('/', File::SEPARATOR))
            FileUtils.mkdir_p(File.dirname(dest))
            rest.sign_on_redirect = false
            tempfile = rest.get_rest(segment_file['url'], true)
            FileUtils.mv(tempfile.path, dest)
          end
        end

        destination
      end

      # Validates the options hash given to the constructor.
      #
      # @param [Hash] options
      #
      # @raise [InvalidChefAPILocation] if any of the options are missing or their values do not
      #   pass validation
      def validate_options!(options)
        if options[:chef_api] == :config
          return true
        end

        missing_options = [:node_name, :client_key] - options.keys

        unless missing_options.empty?
          missing_options.collect! { |opt| "'#{opt}'" }
          raise InvalidChefAPILocation, "Source '#{name}' is a 'chef_api' location with a URL for it's value but is missing options: #{missing_options.join(', ')}."
        end

        self.class.validate_node_name!(options[:node_name])
        self.class.validate_client_key!(options[:client_key])
        self.class.validate_uri!(options[:chef_api])
      end
  end
end
