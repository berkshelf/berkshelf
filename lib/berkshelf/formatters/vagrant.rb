module Berkshelf
  module Formatters
    # @author Jamie Winsor <jamie@vialstudios.com>
    class Vagrant
      include AbstractFormatter

      register_formatter :vagrant

      def initialize
        @ui = ::Vagrant::UI::Colored.new("Berkshelf")
      end

      # Output a Cookbook installation message using {Berkshelf.ui}
      #
      # @param [String] cookbook
      # @param [String] version
      # @param [~Location] location
      def install(cookbook, version, location)
        ui.info "Installing #{cookbook} (#{version}) from #{location}", ui
      end

      # Output a Cookbook use message using {Berkshelf.ui}
      #
      # @param [String] cookbook
      # @param [String] version
      # @param [String] path
      def use(cookbook, version, path = nil)
        ui.info "Using #{cookbook} (#{version})#{' at '+path if path}"
      end

      # Output a Cookbook upload message using {Berkshelf.ui}
      #
      # @param [String] cookbook
      # @param [String] version
      # @param [String] chef_api_url
      def upload(cookbook, version, chef_api_url)
        ui.info "Uploading #{cookbook} (#{version}) to: '#{chef_api_url}'"
      end

      # Output a generic message using {Berkshelf.ui}
      #
      # @param [String] message
      def msg(message)
        ui.info message
      end

      # Output an error message using {Berkshelf.ui}
      #
      # @param [String] message
      def error(message)
        ui.error message
      end

      private

        attr_reader :ui
    end
  end
end
