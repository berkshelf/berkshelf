class Thor
  module CoreExt #:nodoc:
    class HashWithIndifferentAccess < ::Hash
      def has_key?(key)
        super(convert_key(key))
      end

      def fetch(key, default = nil)
        if default
          super(convert_key(key), default)
        else
          super(convert_key(key))
        end
      end
    end
  end
end
