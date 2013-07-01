module Berkshelf
  module Formatters
    class Null
      include AbstractFormatter

      register_formatter :null

      # The abstract formatter dynamically defines methods that raise an
      # AbstractFunction error. We need to define all of those on our class,
      # otherwise they will be inherited by the Ruby object model.
      AbstractFormatter.instance_methods.each do |meth|
        define_method(meth) do |*args|
          # intentionally do nothing
        end
      end

      def method_missing(meth, *args, &block)
        # intentionally do nothing
      end
    end
  end
end
