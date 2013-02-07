require 'vagrant/errors'

module Berkshelf
  # A wrapper for a BerkshelfError for Vagrant. All Berkshelf exceptions should be
  # wrapped in this proxy object so they are properly handled when Vagrant encounters
  # an exception.
  #
  # @example wrapping an error encountered within the Vagrant plugin
  #   rescue BerkshelfError => e
  #     VagrantWrapperError.new(e)
  #   end
  class VagrantWrapperError < Vagrant::Errors::VagrantError
    # @param [BerkshelfError]
    attr_reader :original

    # @param [BerkshelfError] original
    def initialize(original)
      @original = original
    end

    def to_s
      "#{original.class}: #{original.to_s}"
    end

    private

      def method_missing(fun, *args, &block)
        original.send(fun, *args, &block)
      end
  end
end
