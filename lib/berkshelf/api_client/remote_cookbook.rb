module Berkshelf
  class APIClient
    class RemoteCookbook
      # @return [String]
      attr_reader :name
      # @return [String]
      attr_reader :version

      # @param [String] name
      # @param [String] version
      # @param [Hash] attributes
      def initialize(name, version, attributes = {})
        @name       = name
        @version    = version
        @attributes = attributes
      end

      # @return [Hash]
      def dependencies
        @attributes[:dependencies]
      end

      # @return [Hash]
      def platforms
        @attributes[:platforms]
      end

      # @return [Symbol]
      def location_type
        @attributes[:location_type].to_sym
      end

      # @return [String]
      def location_path
        @attributes[:location_path]
      end
    end
  end
end
