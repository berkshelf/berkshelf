module Berkshelf
  module Formatters
    # @abstract Include and override {#install} {#use} {#upload} 
    #   {#shims_written} {#msg} {#error} to implement.
    #
    #   Implement {#cleanup_hook} to run any steps required to run after the task is finished
    module AbstractFormatter
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

      def shims_written(directory)
        raise AbstractFunction, "#shims_written must be implemented on #{self.class}"
      end

      def msg(message)
        raise AbstractFunction, "#msg must be implemented on #{self.class}"
      end

      def error(message)
        raise AbstractFunction, "#error must be implemented on #{self.class}"
      end
    end
  end
end

Dir["#{File.dirname(__FILE__)}/formatters/*.rb"].sort.each do |path|
  require "berkshelf/formatters/#{File.basename(path, '.rb')}"
end
