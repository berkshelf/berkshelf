require 'berkshelf/formatters/formatter'

module Berkshelf
  module Formatters
    class HumanReadable
      include Formatter

      def install(cookbook, version, location)
        Berkshelf.ui.info "Installing #{cookbook} (#{version}) from #{location}"
      end

      def use(cookbook, version, path=nil)
        Berkshelf.ui.info "Using #{cookbook} (#{version})#{' at '+path if path}"
      end

      def upload(cookbook, version, chef_server_url)
        Berkshelf.ui.info "Uploading #{cookbook} (#{version}) to: '#{chef_server_url}'"
      end

      def shims_written(directory)
        Berkshelf.ui.info "Shims written to: '#{directory}'"
      end

      def msg(message)
        Berkshelf.ui.info message
      end

      def error(message)
        Berkshelf.ui.error message
      end
    end
  end
end
