class Thor
  module CoreExt #:nodoc:
    class HashWithIndifferentAccess < ::Hash
      def has_key?(key)
        super(convert_key(key))
      end
    end
  end
end
