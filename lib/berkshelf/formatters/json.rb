require 'berkshelf/formatters/formatter'

module Berkshelf
  module Formatters
    class JSON
      include Formatter

      def initialize
        @output = {cookbooks: [], errors: [], messages: []}
        @cookbooks = {}
        super
      end

      def cleanup_hook
        @cookbooks.each do |name, details|
          details[:name] = name
          @output[:cookbooks] << details
        end
        print @output.to_json
      end

      def install(cookbook, version, location)
        @cookbooks[cookbook] ||= {}
        @cookbooks[cookbook][:version] = version
        @cookbooks[cookbook][:location] = location
      end

      def use(cookbook, version, path=nil)
        @cookbooks[cookbook] ||= {}
        @cookbooks[cookbook][:version] = version
        @cookbooks[cookbook][:location] = path if path
      end

      def upload(cookbook, version, chef_server_url)
        @cookbooks[cookbook] ||= {}
        @cookbooks[cookbook][:version] = version
        @cookbooks[cookbook][:uploaded_to] = chef_server_url
      end

      def shims_written(directory)
        @output[:shims_dir] = directory
      end

      def msg(message)
        @output[:messages] << message
      end

      def error(message)
        @output[:errors] << message
      end
    end
  end
end
