module Berkshelf
  # @author Michael Ivey <michael.ivey@riotgames.com>
  # @author Jamie Winsor <reset@riotgames.com>
  module Formatters
    class << self
      @@formatters = Hash.new

      # Access the formatters map that links string symbols to Formatter
      # implementations
      #
      # @return [Hash]
      def formatters
        @@formatters
      end

      # @param [#to_sym] id
      # @param [Constant] klass
      #
      # @raise [Berkshelf::InternalError] if an ID that has already been registered is attempted
      #   to be registered again
      #
      # @return [Hash]
      #   a hash of registered formatters
      def register(id, klass)
        unless id.respond_to?(:to_sym)
          raise ArgumentError, "Invalid Formatter ID: must respond to #to_sym. You gave: #{id}"
        end

        id = id.to_sym
        if self.formatters.has_key?(id)
          raise Berkshelf::InternalError, "Formatter ID '#{id}' already registered"
        end

        self.formatters[id] = klass
      end

      # @param [#to_sym] id
      #
      # @return [~AbstractFormatter, nil]
      def get(id)
        unless id.respond_to?(:to_sym)
          raise ArgumentError, "Invalid Formatter ID: must respond to #to_sym. You gave: #{id}"
        end

        self.formatters.fetch(id.to_sym, nil)
      end
      alias_method :[], :get
    end

    # @author Michael Ivey <michael.ivey@riotgames.com>
    #
    # @abstract Include and override {#install} {#use} {#upload}
    #   {#msg} {#error} to implement.
    #
    #   Implement {#cleanup_hook} to run any steps required to run after the task is finished
    module AbstractFormatter
      extend ActiveSupport::Concern

      module ClassMethods
        # @param [Symbol] id
        #
        # @raise [Berkshelf::InternalError] if an ID that has already been registered is attempted
        #   to be registered again
        #
        # @return [Hash]
        #   a hash of registered formatters
        def register_formatter(id)
          Formatters.register(id, self)
        end
      end

      def cleanup_hook
        # run after the task is finished
      end

      def install(cookbook, version, location)
        raise AbstractFunction, "#install must be implemented on #{self.class}"
      end

      def use(cookbook, version, path = nil)
        raise AbstractFunction, "#install must be implemented on #{self.class}"
      end

      def upload(cookbook, version, chef_server_url)
        raise AbstractFunction, "#upload must be implemented on #{self.class}"
      end

      def msg(message)
        raise AbstractFunction, "#msg must be implemented on #{self.class}"
      end

      def error(message)
        raise AbstractFunction, "#error must be implemented on #{self.class}"
      end

      private

        attr_reader :args
    end
  end
end

Dir["#{File.dirname(__FILE__)}/formatters/*.rb"].sort.each do |path|
  require "berkshelf/formatters/#{File.basename(path, '.rb')}"
end
