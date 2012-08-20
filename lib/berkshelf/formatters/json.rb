require 'berkshelf/formatters/formatter'

module Berkshelf
  module Formatters
    class JSON
      include Formatter

      def initialize
        @output = {}
        super
      end

      def cleanup_hook
        print @output.to_json
      end

      def install(cookbook, version, location)
        @output['cookbooks'] ||= []
        @output['cookbooks'] << {name: cookbook, version: version, location: location}
      end

      # def use(cookbook, version, path=nil)
      #   Berkshelf.ui.info "Using #{cookbook} (#{version})#{' at '+path if path}"
      # end

      # def upload(cookbook, version, chef_server_url)
      #   Berkshelf.ui.info "Uploading #{cookbook} (#{version}) to: '#{chef_server_url}'"
      # end

      # def shims_written(directory)
      #   Berkshelf.ui.info "Shims written to: '#{directory}'"
      # end

      # def msg(message)
      #   Berkshelf.ui.info message
      # end

      # def error(message)
      #   Berkshelf.ui.error message
      # end
    end
  end
end
