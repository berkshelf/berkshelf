require 'addressable/uri'

module Berkshelf
  class SourceURI < Addressable::URI
    class << self
      # Returns a URI object based on the parsed string.
      #
      # @param [String, Addressable::URI, #to_str] uri
      #   The URI string to parse.
      #   No parsing is performed if the object is already an
      #   <code>Addressable::URI</code>.
      #
      # @raise [Berkshelf::InvalidSourceURI]
      #
      # @return [Berkshelf::SourceURI]
      def parse(uri)
        parsed_uri = super(uri)
        parsed_uri.send(:validate)
        parsed_uri
      rescue TypeError, ArgumentError => ex
        raise InvalidSourceURI.new(uri, ex)
      end
    end

    VALID_SCHEMES = [ "http", "https" ].freeze

    # @raise [Berkshelf::InvalidSourceURI]
    def validate
      super

      unless VALID_SCHEMES.include?(self.scheme)
        raise InvalidSourceURI.new(self, "invalid URI scheme '#{self.scheme}'. Valid schemes: #{VALID_SCHEMES}")
      end
    rescue Addressable::URI::InvalidURIError => ex
      raise InvalidSourceURI.new(self, ex)
    end
  end
end
