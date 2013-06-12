module Berkshelf
  module Formatters
    class JSON
      include AbstractFormatter

      register_formatter :json

      def initialize
        Berkshelf.ui.mute!

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

        print ::JSON.pretty_generate(output)
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
      # @param [~Location] location
      def use(cookbook, version, location = nil)
        cookbooks[cookbook] ||= {}
        cookbooks[cookbook][:version] = version

        if location && location.is_a?(PathLocation)
          cookbooks[cookbook][:metadata] = true if location.metadata?
          cookbooks[cookbook][:location] = location.relative_path
        end
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

      # Add a Cookbook package entry to delayed output
      #
      # @param [String] cookbook
      # @param [String] destination
      def package(cookbook, destination)
        cookbooks[cookbook] ||= {}
        cookbooks[cookbook][:destination] = destination
      end

      # Output Cookbook info entry to delayed output
      #
      # @param [CachedCookbook] cookbook
      def show(cookbook)
        cookbooks[cookbook.cookbook_name] = cookbook.pretty_hash
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
