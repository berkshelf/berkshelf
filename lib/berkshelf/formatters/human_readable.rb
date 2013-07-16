module Berkshelf
  module Formatters
    class HumanReadable
      include AbstractFormatter

      register_formatter :human

      # @param [Berkshelf::Dependency] dependency
      def fetch(dependency)
        Berkshelf.ui.info "Fetching '#{dependency.name}' from #{dependency.location}"
      end

      # Output a Cookbook installation message using {Berkshelf.ui}
      #
      # @param [String] cookbook
      # @param [String] version
      # @param [Berkshelf::Dependency] dependency
      def install(cookbook, version, dependency)
        Berkshelf.ui.info "Installing #{cookbook} (#{version})"
      end

      # Output a Cookbook use message using {Berkshelf.ui}
      #
      # @param [String] cookbook
      # @param [String] version
      # @param [~Location] location
      def use(cookbook, version, location = nil)
        message = "Using #{cookbook} (#{version})"
        message += " #{location}" if location
        Berkshelf.ui.info message
      end

      # Output a Cookbook upload message using {Berkshelf.ui}
      #
      # @param [String] cookbook
      # @param [String] version
      # @param [String] chef_api_url
      def upload(cookbook, version, chef_api_url)
        Berkshelf.ui.info "Uploading #{cookbook} (#{version}) to: '#{chef_api_url}'"
      end

      # Output a Cookbook package message using {Berkshelf.ui}
      #
      # @param [String] cookbook
      # @param [String] destination
      def package(cookbook, destination)
        Berkshelf.ui.info "Cookbook(s) packaged to #{destination}!"
      end

      # Output Cookbook info message using {Berkshelf.ui}
      #
      # @param [CachedCookbook] cookbook
      def show(cookbook)
        Berkshelf.ui.info(cookbook.pretty_print)
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

      # Output a deprecation warning
      #
      # @param [String] message
      def deprecation(message)
        Berkshelf.ui.info "DEPRECATED: #{message}"
      end
    end
  end
end
