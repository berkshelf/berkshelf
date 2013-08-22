module Berkshelf
  class ChefAPILocation
    class << self
      # @return [Proc]
      def finalizer
        proc { conn.terminate if defined?(conn) && conn.alive? }
      end

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
    # @option options [String] :node_name (Berkshelf::Config.instance.chef.node_name)
    #   the name of the client to use to communicate with the Chef API.
    # @option options [String] :client_key (Berkshelf::Config.instance.chef.client_key)
    #   the filepath to the authentication key for the client
    # @option options [Boolean] :verify_ssl (Berkshelf::Config.instance.chef.ssl.verify)
    #
    # @raise [ClientKeyFileNotFound] if the value for :client_key does not contain a filepath
    #   pointing to a readable file containing a Chef client key.
    #
    #   If the :chef_api option is given the symbol :config and your Berkshelf config does not
    #   have a value for chef.client_key which points to a readable file containing a Chef
    #   client key.
    def initialize(name, version_constraint, options = {})
      options = options.reverse_merge(
        client_key: Berkshelf::Config.instance.chef.client_key,
        node_name: Berkshelf::Config.instance.chef.node_name,
        verify_ssl: Berkshelf::Config.instance.ssl.verify
      )

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

          msg = "A Berkshelf configuration is required with a 'chef.client_key', 'chef.chef_server_Url',"
          msg << " and 'chef.node_name' setting to install or upload cookbooks using 'chef_api :config'."

          raise Berkshelf::ConfigurationError, msg
        end
        @node_name  = Berkshelf::Config.instance.chef.node_name
        @client_key = Berkshelf::Config.instance.chef.client_key
        @uri        = Berkshelf::Config.instance.chef.chef_server_url
      else
        @node_name  = options[:node_name]
        @client_key = options[:client_key]
        @uri        = options[:chef_api]
      end

      @conn = Ridley.new(
        server_url: uri,
        client_name: node_name,
        client_key: client_key,
        ssl: {
          verify: options[:verify_ssl]
        }
      )

      # Why do we use a class function for defining our finalizer?
      # http://www.mikeperham.com/2010/02/24/the-trouble-with-ruby-finalizers/
      ObjectSpace.define_finalizer(self, self.class.finalizer)
    rescue Ridley::Errors::ClientKeyFileNotFoundOrInvalid => ex
      raise ClientKeyFileNotFound, ex
    end

    # @param [#to_s] destination
    #
    # @return [Berkshelf::CachedCookbook]
    def download(destination)
      berks_path = File.join(destination, "#{name}-#{target_cookbook.version}")

      temp_path = target_cookbook.download
      FileUtils.mv(temp_path, berks_path)

      cached = CachedCookbook.from_store_path(berks_path)
      validate_cached(cached)

      cached
    end

    # Returns a Ridley::CookbookResource representing the cookbook that should be downloaded
    # for this location
    #
    # @return [Ridley::CookbookResource]
    def target_cookbook
      return @target_cookbook unless @target_cookbook.nil?

      begin
        @target_cookbook = if version_constraint
          conn.cookbook.satisfy(name, version_constraint)
        else
          conn.cookbook.latest_version(name)
        end
      rescue Ridley::Errors::HTTPNotFound,
             Ridley::Errors::ResourceNotFound
        @target_cookbook = nil
      end

      if @target_cookbook.nil?
        msg = "Cookbook '#{name}' found at #{self}"
        msg << " that would satisfy constraint (#{version_constraint})" if version_constraint
        raise CookbookNotFound, msg
      end

      @target_cookbook
    end

    def to_hash
      super.merge(value: self.uri)
    end

    def to_s
      "#{self.class.location_key}: '#{uri}'"
    end

    private

      # @return [Ridley::Client]
      attr_reader :conn

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
          msg = "Source '#{name}' is a 'chef_api' location with a URL for it's value"
          msg << " but is missing options: #{missing_options.join(', ')}."

          raise Berkshelf::InvalidChefAPILocation, msg
        end

        self.class.validate_node_name!(options[:node_name])
        self.class.validate_client_key!(options[:client_key])
        self.class.validate_uri!(options[:chef_api])
      end
  end
end
