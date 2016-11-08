require 'berkshelf/api-client'

module Berkshelf
  class Source
    include Comparable

    attr_accessor :source

    # @param [String, Berkshelf::SourceURI] source
    def initialize(source, args=[])
      @source = source
      @universe   = nil
      @filter = Hash.new
      if args.count > 0 and args.first.is_a?( Hash )
        args.first.each do |k,v|
          begin
            @filter[k] = Regexp.new( v )
          rescue
            Berkself.ui.warn "Invalid source #{k} regex '#{v}'"
          end
        end
      end
    end

    def api_client
      @api_client ||= begin
                        if source == :chef_server
                          APIClient.chef_server(
                            ssl: Berkshelf::Config.instance.ssl,
                            timeout: api_timeout,
                            open_timeout: [(api_timeout / 10), 3].max,
                            client_name: Berkshelf::Config.instance.chef.node_name,
                            server_url: Berkshelf::Config.instance.chef.chef_server_url,
                            client_key: Berkshelf::Config.instance.chef.client_key,
                          )
                        else
                          APIClient.new(uri,
                            timeout: api_timeout,
                            open_timeout: [(api_timeout / 10), 3].max,
                            ssl: Berkshelf::Config.instance.ssl
                                       )
                        end
                      end
    end

    def uri
      @uri ||= if source == :chef_server
                 SourceURI.parse(Berkshelf::Config.instance.chef.chef_server_url)
               else
                 SourceURI.parse(source)
               end
    end

    # Forcefully obtain the universe from the API endpoint and assign it to {#universe}. This
    # will reload the value of {#universe} even if it has been loaded before.
    #
    # @return [Array<APIClient::RemoteCookbook>]
    def build_universe
      cookbooks = api_client.universe
      if @filter[:include]
        cookbooks.select! { |rc| rc.name =~ @filter[:include] }
      end
      if @filter[:exclude]
        cookbooks.reject! { |rc| rc.name =~ @filter[:exclude] }
      end
      @universe = cookbooks
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
      "#{uri}"
    end

    def inspect
      "#<#{self.class.name} uri: #{@uri.to_s.inspect}>"
    end

    def hash
      @uri.host.hash
    end

    def ==(other)
      return false unless other.is_a?(self.class)
      uri == other.uri
    end

    private

    def api_timeout
      Berkshelf::Config.instance.api.timeout.to_i
    end
  end
end
