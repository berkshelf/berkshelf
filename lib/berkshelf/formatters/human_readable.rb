module Berkshelf
  module Formatters
    # @author Michael Ivey <michael.ivey@riotgames.com>
    class HumanReadable
      include AbstractFormatter

      register_formatter :human

      # Output a Cookbook installation message using {Berkshelf.ui}
      #
      # @param [String] cookbook
      # @param [String] version
      # @param [~Location] location
      def install(cookbook, version, location)
        Berkshelf.ui.info "Installing #{cookbook} (#{version}) from #{location}"
      end

      # Output a Cookbook use message using {Berkshelf.ui}
      #
      # @param [String] cookbook
      # @param [String] version
      # @param [String] path
      def use(cookbook, version, path = nil)
        Berkshelf.ui.info "Using #{cookbook} (#{version})#{' at '+path if path}"
      end

      # Output a Cookbook upload message using {Berkshelf.ui}
      #
      # @param [String] cookbook
      # @param [String] version
      # @param [String] chef_api_url
      def upload(cookbook, version, chef_api_url)
        Berkshelf.ui.info "Uploading #{cookbook} (#{version}) to: '#{chef_api_url}'"
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
