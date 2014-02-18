module Berkshelf
  class Location
    class << self
      # Create a new instance of a Location class given dependency and options.
      # The type of class is determined by the values in the given +options+
      # Hash.
      #
      # If you do not provide an option with a matching location id, +nil+
      # is returned.
      #
      # @example Create a git location
      #   Location.init(dependency, git: 'git://github.com/berkshelf/berkshelf.git')
      #
      # @example Create a GitHub location
      #   Location.init(dependency, github: 'berkshelf/berkshelf')
      #
      # @param [Dependency] dependency
      # @param [Hash] options
      #
      # @return [~BaseLocation, nil]
      def init(dependency, options = {})
        if klass = klass_from_options(options)
          klass.new(dependency, options)
        else
          nil
        end
      end

      private

      # Load the correct location from the given options.
      #
      # @return [Class, nil]
      def klass_from_options(options)
        options.each do |key, _|
          id = key.to_s.capitalize

          begin
            return Berkshelf.const_get("#{id}Location")
          rescue NameError; end
        end

        nil
      end
    end
  end
end
