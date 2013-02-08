module Berkshelf
  # This superclass is responsible for handling common command methods and options.
  #
  # @author Seth Vargo <sethvargo@gmail.com>
  module Command
    private
      # Validate the options hash, ensuring there are no conflicting arguments
      #
      # @raise [Berkshelf::ArgumentError]
      #   if there are conflicting or invalid options
      def validate_options!(options)
        if options[:except] && options[:only]
          raise ArgumentError, "Cannot specify both :except and :only"
        end

        if options[:cookbooks] && (options[:except] || options[:only])
          Berkshelf.ui.warn ":cookbooks were supplied to update(), so :except and :only are ignored..."
        end
      end
  end
end
