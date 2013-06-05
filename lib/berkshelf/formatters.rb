module Berkshelf
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

      class << self
        private

        def formatter_methods(*args)
          args.each do |meth|
            define_method(meth.to_sym) do |*args|
              raise AbstractFunction, "##{meth} must be implemented on #{self.class}"
            end unless respond_to?(meth.to_sym)
          end
        end
      end

      formatter_methods :install, :use, :upload, :msg, :error, :package, :show

      def cleanup_hook
        # run after the task is finished
      end

      private

        attr_reader :args
    end
  end
end

Dir["#{File.dirname(__FILE__)}/formatters/*.rb"].sort.each do |path|
  require_relative "formatters/#{File.basename(path, '.rb')}"
end
