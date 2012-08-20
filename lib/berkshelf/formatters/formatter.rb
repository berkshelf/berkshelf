module Berkshelf
  module Formatters

    class MethodNotImplmentedError < ::Berkshelf::InternalError ; end

    module Formatter

      def cleanup_hook
        # run after the task is finished
      end

      def install(cookbook, version, location)
        raise MethodNotImplmentedError, "#install must be implemented on #{self.class}"
      end

      def use(cookbook, version, path=nil)
        raise MethodNotImplmentedError, "#install must be implemented on #{self.class}"
      end

      def upload(cookbook, version, chef_server_url)
        raise MethodNotImplmentedError, "#upload must be implemented on #{self.class}"
      end

      def shims_written(directory)
        raise MethodNotImplmentedError, "#shims_written must be implemented on #{self.class}"
      end

      def msg(message)
        raise MethodNotImplmentedError, "#msg must be implemented on #{self.class}"
      end

      def error(message)
        raise MethodNotImplmentedError, "#error must be implemented on #{self.class}"
      end

    end
  end
end
