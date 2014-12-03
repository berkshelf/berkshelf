module Berkshelf
  class HumanFormatter < BaseFormatter
    # Output the version of Berkshelf
    def version
      Berkshelf.ui.info Berkshelf::VERSION
    end

    # @param [Berkshelf::Dependency] dependency
    def fetch(dependency)
      Berkshelf.ui.info "Fetching '#{dependency.name}' from #{dependency.location}"
    end

    # Output a Cookbook installation message using {Berkshelf.ui}
    #
    # @param [Source] source
    #   the source the dependency is being downloaded from
    # @param [RemoteCookbook] cookbook
    #   the cookbook to be downloaded
    def install(source, cookbook)
      message = "Installing #{cookbook.name} (#{cookbook.version})"

      unless source.default?
        message << " from #{source}"
        message << " ([#{cookbook.location_type}] #{cookbook.location_path})"
      end

      Berkshelf.ui.info(message)
    end

    # Output a Cookbook use message using {Berkshelf.ui}
    #
    # @param [Dependency] dependency
    def use(dependency)
      message =  "Using #{dependency.name} (#{dependency.locked_version})"
      message << " from #{dependency.location}" if dependency.location
      Berkshelf.ui.info(message)
    end

    # Output a Cookbook upload message using {Berkshelf.ui}
    #
    # @param [Berkshelf::CachedCookbook] cookbook
    # @param [Ridley::Connection] conn
    def uploaded(cookbook, conn)
      Berkshelf.ui.info "Uploaded #{cookbook.cookbook_name} (#{cookbook.version}) to: '#{conn.server_url}'"
    end

    # Output a Cookbook skip message using {Berkshelf.ui}
    #
    # @param [Berkshelf::CachedCookbook] cookbook
    # @param [Ridley::Connection] conn
    def skipping(cookbook, conn)
      Berkshelf.ui.info "Skipping #{cookbook.cookbook_name} (#{cookbook.version}) (frozen)"
    end

    # Output a list of outdated cookbooks and the most recent version
    # using {Berkshelf.ui}
    #
    # @param [Hash] hash
    #   the list of outdated cookbooks in the format
    #   { 'cookbook' => { 'supermarket.chef.io' => #<Cookbook> } }
    def outdated(hash)
      if hash.empty?
        Berkshelf.ui.info('All cookbooks up to date!')
      else
        Berkshelf.ui.info('The following cookbooks have newer versions:')

        hash.each do |name, info|
          info['remote'].each do |remote_source, remote_version|
            out = "  * #{name} (#{info['local']} => #{remote_version})"

            unless remote_source.default?
              out << " [#{remote_source.uri}]"
            end

            Berkshelf.ui.info(out)
          end
        end
      end
    end

    # Output a Cookbook package message using {Berkshelf.ui}
    #
    # @param [String] destination
    def package(destination)
      Berkshelf.ui.info "Cookbook(s) packaged to #{destination}"
    end

    # Output the important information about a cookbook using {Berkshelf.ui}.
    #
    # @param [CachedCookbook] cookbook
    def info(cookbook)
      Berkshelf.ui.info(cookbook.pretty_print)
    end

    # Output a list of cookbooks using {Berkshelf.ui}
    #
    # @param [Array<Dependency>] list
    def list(dependencies)
      Berkshelf.ui.info "Cookbooks installed by your Berksfile:"
      dependencies.each do |dependency|
        out =  "  * #{dependency}"
        out << " from #{dependency.location}" if dependency.location
        Berkshelf.ui.info(out)
      end
    end

    # Ouput Cookbook search results using {Berkshelf.ui}
    #
    # @param [Array<APIClient::RemoteCookbook>] results
    def search(results)
      results.sort_by(&:name).each do |remote_cookbook|
        Berkshelf.ui.info "#{remote_cookbook.name} (#{remote_cookbook.version})"
      end
    end

    # Output Cookbook path using {Berkshelf.ui}
    #
    # @param [CachedCookbook] cookbook
    def show(cookbook)
      path = File.expand_path(cookbook.path)
      Berkshelf.ui.info(path)
    end

    # Output Cookbook vendor info message using {Berkshelf.ui}
    #
    # @param [CachedCookbook] cookbook
    # @param [String] destination
    def vendor(cookbook, destination)
      cookbook_destination = File.join(destination, cookbook.cookbook_name)
      Berkshelf.ui.info "Vendoring #{cookbook.cookbook_name} (#{cookbook.version}) to #{cookbook_destination}"
    end

    # Output a generic message using {Berkshelf.ui}
    #
    # @param [String] message
    def msg(message)
      Berkshelf.ui.info message
    end

    # Output an error message using {Berkshelf.ui}
    #
    # @param [String] message
    def error(message)
      Berkshelf.ui.error message
    end

    # Output a warning message using {Berkshelf.ui}
    #
    # @param [String] message
    def warn(message)
      Berkshelf.ui.warn message
    end

    # Output a deprecation warning
    #
    # @param [String] message
    def deprecation(message)
      Berkshelf.ui.info "DEPRECATED: #{message}"
    end
  end
end
