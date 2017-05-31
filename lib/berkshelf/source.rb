require "berkshelf/api-client"
require "berkshelf/chef_repo_universe"
require "berkshelf/ssl_policies"
require "openssl"

module Berkshelf
  class Source
    include Comparable

    attr_accessor :type
    attr_accessor :uri_string
    attr_accessor :options

    # @param [Berkshelf::Berksfile] berksfile
    # @param [String, Berkshelf::SourceURI] source
    def initialize(berksfile, source, **options)
      @options = { timeout: api_timeout, open_timeout: [(api_timeout / 10), 3].max, ssl: {} }
      @options.update(options)
      case source
      when String
        # source "https://supermarket.chef.io/"
        @type = :supermarket
        @uri_string = source
      when :chef_server
        # source :chef_server
        @type = :chef_server
        @uri_string = options[:url] || Berkshelf::Config.instance.chef.chef_server_url
      when Hash
        # source type: uri, option: value, option: value
        source = source.dup
        @type, @uri_string = source.shift
        @options.update(source)
      end
      # Default options for some source types.
      case @type
      when :chef_server
        @options[:client_name] ||= Berkshelf::Config.instance.chef.node_name
        @options[:client_key] ||= Berkshelf::Config.instance.chef.client_key
      when :artifactory
        @options[:api_key] ||= Berkshelf::Config.instance.chef.artifactory_api_key || ENV["ARTIFACTORY_API_KEY"]
      when :chef_repo
        @options[:path] = uri_string
        # If given a relative path, expand it against the Berksfile's folder.
        @options[:path] = File.expand_path(@options[:path], File.dirname(berksfile ? berksfile.filepath : Dir.pwd))
        # Lie because this won't actually parse as a URI.
        @uri_string = "file://#{@options[:path]}"
      end
      # Set some default SSL options.
      Berkshelf::Config.instance.ssl.each do |key, value|
        @options[:ssl][key.to_sym] = value unless @options[:ssl].include?(key.to_sym)
      end
      @options[:ssl][:cert_store] = ssl_policy.store if ssl_policy.store
      @universe = nil
    end

    def ssl_policy
      @ssl_policy ||= SSLPolicy.new
    end

    def api_client
      @api_client ||= case type
                      when :chef_server
                        APIClient.chef_server(server_url: uri.to_s, **options)
                      when :artifactory
                        # Don't accidentally mutate the options.
                        client_options = options.dup
                        api_key = client_options.delete(:api_key)
                        APIClient.new(uri, headers: { "X-Jfrog-Art-Api" => api_key }, **client_options)
                      when :chef_repo
                        ChefRepoUniverse.new(uri_string, **options)
                      else
                        APIClient.new(uri, **options)
                      end
    end

    def uri
      @uri ||= SourceURI.parse(uri_string)
    end

    # Forcefully obtain the universe from the API endpoint and assign it to {#universe}. This
    # will reload the value of {#universe} even if it has been loaded before.
    #
    # @return [Array<APIClient::RemoteCookbook>]
    def build_universe
      @universe = api_client.universe
    rescue => ex
      @universe = Array.new
      raise ex
    end

    # Return the universe from the API endpoint.
    #
    # This is lazily loaded so the universe will be retrieved from the API endpoint on the first
    # call and cached for future calls. Send the {#build_universe} message if you want to reload
    # the cached universe.
    #
    # @return [Array<APIClient::RemoteCookbook>]
    def universe
      @universe || build_universe
    end

    # @param [String] name
    # @param [String] version
    #
    # @return [APIClient::RemoteCookbook]
    def cookbook(name, version)
      universe.find { |cookbook| cookbook.name == name && cookbook.version == version }
    end

    # The list of remote cookbooks that match the given query.
    #
    # @param [String] name
    #
    # @return [Array<APIClient::RemoteCookbook]
    def search(name)
      universe
        .select { |cookbook| cookbook.name =~ Regexp.new(name) }
        .group_by(&:name)
        .collect { |_, versions| versions.max_by { |v| Semverse::Version.new(v.version) } }
    end

    # Determine if this source is a "default" source, as defined in the
    # {Berksfile}.
    #
    # @return [true, false]
    #   true if this a default source, false otherwise
    def default?
      @default_ ||= uri.host == URI.parse(Berksfile::DEFAULT_API_URL).host
    end

    # @param [String] name
    #
    # @return [APIClient::RemoteCookbook]
    def latest(name)
      versions(name).sort.last
    end

    # @param [String] name
    #
    # @return [Array<APIClient::RemoteCookbook>]
    def versions(name)
      universe.select { |cookbook| cookbook.name == name }
    end

    def to_s
      case type
      when :supermarket
        uri.to_s
      when :chef_repo
        options[:path]
      else
        "#{type}: #{uri}"
      end
    end

    def inspect
      "#<#{self.class.name} #{type}: #{uri.to_s.inspect}, #{options.map { |k, v| "#{k}: #{v.inspect}" }.join(', ')}>"
    end

    def hash
      [type, uri_string, options].hash
    end

    def ==(other)
      return false unless other.is_a?(self.class)
      type == other.type && uri == other.uri
    end

    private

    def api_timeout
      Berkshelf::Config.instance.api.timeout.to_i
    end
  end
end
