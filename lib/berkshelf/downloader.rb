module Berkshelf
  class Downloader
    extend Forwardable

    attr_reader :berksfile

    def_delegators :berksfile, :sources

    # @param [Berkshelf::Berksfile] berksfile
    def initialize(berksfile)
      @berksfile = berksfile
    end

    # Download the given Berkshelf::Dependency.
    #
    # @param [String] name
    # @param [String] version
    #
    # @option options [String] :path
    #
    # @raise [CookbookNotFound]
    #
    # @return [String]
    def download(*args)
      options = args.last.is_a?(Hash) ? args.pop : Hash.new
      dependency, version = args

      if dependency.is_a?(Berkshelf::Dependency)
        dependency.download(Berkshelf::CookbookStore.instance.storage_path)
      else
        sources.each do |source|
          if result = try_download(source, dependency, version)
            return result
          end
        end

        raise CookbookNotFound, "#{dependency} (#{version}) not found in any sources"
      end
    end

    # @param [Berkshelf::Source] source
    # @param [String] name
    # @param [String] version
    #
    # @return [String]
    def try_download(source, name, version)
      unless remote_cookbook = source.cookbook(name, version)
        return nil
      end

      case remote_cookbook.location_type
      when :opscode
        CommunityREST.new(remote_cookbook.location_path).download(name, version)
      when :chef_server
        # @todo Dynamically get credentials for remote_cookbook.location_path
        credentials = {
          server_url: remote_cookbook.location_path,
          client_name: Berkshelf::Config.instance.chef.node_name,
          client_key: Berkshelf::Config.instance.chef.client_key,
          ssl: {
            verify: Berkshelf::Config.instance.ssl.verify
          }
        }
        Ridley.open(credentials) { |r| r.cookbook.download(name, version) }
      else
        raise RuntimeError, "unknown location type #{remote_cookbook.location_type}"
      end
    rescue CookbookNotFound
      nil
    end
  end
end
