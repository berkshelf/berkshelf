module Berkshelf
  module Formatters
    class JSON
      include AbstractFormatter

      Berkshelf.formatters["json"] = self

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
        
        print MultiJson.dump(@output)
      end

      def install(cookbook, version, location)
        @cookbooks[cookbook] ||= {}
        @cookbooks[cookbook][:version] = version
        @cookbooks[cookbook][:location] = location.to_s
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

      def msg(message)
        @output[:messages] << message
      end

      def error(message)
        @output[:errors] << message
      end
    end
  end
end
