module Berkshelf
  module Formatters
    # @author Michael Ivey <michael.ivey@riotgames.com>
    class JSON
      include AbstractFormatter

      register_formatter :json

      def initialize
        @output = {
          cookbooks: Array.new,
          errors: Array.new,
          messages: Array.new
        }
        @cookbooks = Hash.new
        super
      end

      def cleanup_hook
        cookbooks.each do |name, details|
          details[:name] = name
          output[:cookbooks] << details
        end

        print MultiJson.dump(output)
      end

      # Add a Cookbook installation entry to delayed output
      #
      # @param [String] cookbook
      # @param [String] version
      # @param [~Location] location
      def install(cookbook, version, location)
        cookbooks[cookbook] ||= {}
        cookbooks[cookbook][:version] = version
        cookbooks[cookbook][:location] = location.to_s
      end

      # Add a Cookbook use entry to delayed output
      #
      # @param [String] cookbook
      # @param [String] version
      # @param [String] path
      def use(cookbook, version, path = nil)
        cookbooks[cookbook] ||= {}
        cookbooks[cookbook][:version] = version
        cookbooks[cookbook][:location] = path if path
      end

      # Add a Cookbook upload entry to delayed output
      #
      # @param [String] cookbook
      # @param [String] version
      # @param [String] chef_api_url
      def upload(cookbook, version, chef_api_url)
        cookbooks[cookbook] ||= {}
        cookbooks[cookbook][:version] = version
        cookbooks[cookbook][:uploaded_to] = chef_api_url
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

      private

        attr_reader :output
        attr_reader :cookbooks
    end
  end
end
