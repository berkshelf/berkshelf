class Thor
  module CoreExt #:nodoc:
    class HashWithIndifferentAccess < ::Hash
      def has_key?(key)
        super(convert_key(key))
      end

      def fetch(key, default = nil)
        super(convert_key(key), default)
      end
    end
  end
end
