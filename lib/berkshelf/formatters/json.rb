module Berkshelf
  class JsonFormatter < BaseFormatter
    # Output the version of Berkshelf
    def version
      @output = { version: Berkshelf::VERSION }
    end

    def initialize
      @output = {
        cookbooks: [],
        errors:    [],
        messages:  [],
        warnings:  [],
      }
      @cookbooks = Hash.new

      Berkshelf.ui.mute { super }
    end

    def cleanup_hook
      cookbooks.each do |name, details|
        details[:name] = name
        output[:cookbooks] << details
      end

      puts ::JSON.pretty_generate(output)
    end

    # @param [Berkshelf::Dependency] dependency
    def fetch(dependency)
      cookbooks[dependency] ||= {}
      cookbooks[dependency][:version]  = dependency.locked_version.to_s
      cookbooks[dependency][:location] = dependency.location
    end

    # Add a Cookbook installation entry to delayed output
    #
    # @param [Source] source
    #   the source the dependency is being downloaded from
    # @param [RemoteCookbook] cookbook
    #   the cookbook to be downloaded
    def install(source, cookbook)
      cookbooks[cookbook.name] ||= {}
      cookbooks[cookbook.name][:version] = cookbook.version

      unless source.default?
        cookbooks[cookbook.name][:api_source]    = source.uri
        cookbooks[cookbook.name][:location_path] = cookbook.location_path
      end
    end

    # Add a Cookbook use entry to delayed output
    #
    # @param [Dependency] dependency
    def use(dependency)
      cookbooks[dependency.name] ||= {}
      cookbooks[dependency.name][:version] = dependency.cached_cookbook.version

      if dependency.location.is_a?(PathLocation)
        cookbooks[dependency.name][:metadata] = true if dependency.location.metadata?
        cookbooks[dependency.name][:location] = dependency.location.relative_path
      end
    end

    # Add a Cookbook upload entry to delayed output
    #
    # @param [Berkshelf::CachedCookbook] cookbook
    # @param [Ridley::Connection] conn
    def uploaded(cookbook, conn)
      name = cookbook.cookbook_name
      cookbooks[name] ||= {}
      cookbooks[name][:version] = cookbook.version
      cookbooks[name][:uploaded_to] = conn.server_url
    end

    # Add a Cookbook skip entry to delayed output
    #
    # @param [Berkshelf::CachedCookbook] cookbook
    # @param [Ridley::Connection] conn
    def skipping(cookbook, conn)
      name = cookbook.cookbook_name
      cookbooks[name] ||= {}
      cookbooks[name][:version] = cookbook.version
      cookbooks[name][:skipped] = true
    end

    # Output a list of outdated cookbooks and the most recent version
    # to delayed output
    #
    # @param [Hash] hash
    #   the list of outdated cookbooks in the format
    #   { 'cookbook' => { 'supermarket.chef.io' => #<Cookbook> } }
    def outdated(hash)
      hash.each do |name, info|
        info['remote'].each do |remote_source, remote_version|
          source = remote_source.uri.to_s

          cookbooks[name] ||= {}
          cookbooks[name][:local] = info['local'].to_s
          cookbooks[name][:remote] ||= {}
          cookbooks[name][:remote][source] = remote_version.to_s
        end
      end
    end

    # Output Cookbook info entry to delayed output.
    #
    # @param [CachedCookbook] cookbook
    def info(cookbook)
      path = File.expand_path(cookbook.path)
      cookbooks[cookbook.cookbook_name] = { path: path }
    end

    # Output a package message using
    #
    # @param [String] destination
    def package(destination)
      output[:messages] << "Cookbook(s) packaged to #{destination}"
    end

    # Output a list of cookbooks to delayed output
    #
    # @param [Array<Dependency>] dependencies
    def list(dependencies)
      dependencies.each do |dependency, cookbook|
        cookbooks[dependency.name] ||= {}
        cookbooks[dependency.name][:version] = dependency.locked_version.to_s
        if dependency.location
          cookbooks[dependency.name][:location] = dependency.location
        end
      end
    end

    # Output Cookbook path entry to delayed output
    #
    # @param [CachedCookbook] cookbook
    def show(cookbook)
      path = File.expand_path(cookbook.path)
      cookbooks[cookbook.cookbook_name] = { path: path }
    end

    # Ouput Cookbook search results to delayed output
    #
    # @param [Array<APIClient::RemoteCookbook>] results
    def search(results)
      results.sort_by(&:name).each do |remote_cookbook|
        cookbooks[remote_cookbook.name] ||= {}
        cookbooks[remote_cookbook.name][:version] = remote_cookbook.version
      end
    end

    # Add a vendor message to delayed output
    #
    # @param [CachedCookbook] cookbook
    # @param [String] destination
    def vendor(cookbook, destination)
      cookbook_destination = File.join(destination, cookbook.cookbook_name)
      msg("Vendoring #{cookbook.cookbook_name} (#{cookbook.version}) to #{cookbook_destination}")
    end

    # Add a generic message entry to delayed output
    #
    # @param [String] message
    def msg(message)
      output[:messages] << message
    end

    # Add an error message entry to delayed output
    #
    # @param [String] message
    def error(message)
      output[:errors] << message
    end

    # Add a warning message entry to delayed output
    #
    # @param [String] message
    def warn(message)
      output[:warnings] << message
    end

    def deprecation(message)
      output[:warnings] << "DEPRECATED: #{message}"
    end

    private

    attr_reader :output
    attr_reader :cookbooks
  end
end
