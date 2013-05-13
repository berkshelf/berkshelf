module Berkshelf
  module Formatters
    # @author Seth Vargo <sethvargo@gmail.com>
    class Null
      include AbstractFormatter

      register_formatter :null

      def method_missing(meth, *args, &block)
        # intentionally do nothing
      end
    end
  end
end
