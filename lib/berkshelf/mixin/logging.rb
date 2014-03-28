module Berkshelf
  module Mixin
    module Logging
      attr_writer :logger

      def logger
        @logger ||= Berkshelf::Logger.new(STDOUT)
      end
      alias_method :log, :logger
    end
  end
end
