module Berkshelf
  module Location
    class << self
      # Creates a new instance of a Class implementing Location with the given name and
      # constraint. Which Class to instantiated is determined by the values in the given
      # options Hash. Source Locations have an associated location_key registered with
      # Berkshelf::Dependency. If your options Hash contains a key matching one of these location_keys
      # then the Class who registered that location_key will be instantiated. If you do not
      # provide an option with a matching location_key nil will be returned.
      #
      # @example
      #   Location.init('nginx', '>= 0.0.0', git: 'git://github.com/RiotGames/artifact-cookbook.git') =>
      #     instantiates a GitLocation
      #
      #
      #   Location.init('nginx', '>= 0.0.0', path: '/Users/reset/code/nginx-cookbook') =>
      #     instantiates a PathLocation
      #
      # @param [Dependency] dependency
      # @param [Hash] options
      #
      # @return [~Location::Base, nil]
      def init(dependency, options = {})
        if klass = klass_from_options(options)
          klass.new(dependency, options)
        end
      end

      private

        def klass_from_options(options)
          location_keys = (options.keys & Berkshelf::Dependency.location_keys.keys)
          if location_keys.length > 1
            location_keys.collect! { |opt| "'#{opt}'" }
            raise InternalError, "Only one location key (#{Berkshelf::Dependency.location_keys.keys.join(', ')}) " +
              "may be specified. You gave #{location_keys.join(', ')}."
          end

          if location_key = location_keys.first
            Berkshelf::Dependency.location_keys[location_key]
          end
        end
    end

    class Base
      class << self
        # Returns the location identifier key for the class
        #
        # @return [Symbol]
        attr_reader :location_key

        # Register the location key for the including source location with Berkshelf::Dependency
        #
        # @param [Symbol] key
        def set_location_key(key)
          Berkshelf::Dependency.add_location_key(key, self)
          @location_key = key
        end

        # Register a valid option or multiple options with the Berkshelf::Dependency class
        #
        # @param [Symbol] opts
        def set_valid_options(*opts)
          Array(opts).each do |opt|
            Berkshelf::Dependency.add_valid_option(opt)
          end
        end
      end

      extend Forwardable

      attr_reader :dependency
      def_delegator :dependency, :name

      # @param [Berkshelf::Dependency] dependency
      # @param [Hash] options
      def initialize(dependency, options = {})
        @dependency       = dependency
        @@cached_cookbook = nil
      end

      # @param [#to_s] destination
      #
      # @return [Berkshelf::CachedCookbook]
      def download
        return @cached_cookbook if @cached_cookbook

        cached_cookbook = do_download
        validate_cached(cached_cookbook)
        @cached_cookbook = cached_cookbook
      end

      # @param [#to_s] destination
      #
      # @return [Berkshelf::CachedCookbook]
      def do_download
        raise AbstractFunction
      end

      # Ensure the retrieved CachedCookbook is valid
      #
      # @param [CachedCookbook] cached_cookbook
      #   the downloaded cookbook to validate
      #
      # @raise [CookbookValidationFailure] if given CachedCookbook does not satisfy the constraint of the location
      #
      # @todo Change MismatchedCookbookName to raise instead of warn
      #
      # @return [Boolean]
      def validate_cached(cached_cookbook)
        unless dependency.version_constraint.satisfies?(cached_cookbook.version)
          raise CookbookValidationFailure.new(dependency, cached_cookbook)
        end

        unless dependency.name == cached_cookbook.cookbook_name
          Berkshelf.ui.warn(MismatchedCookbookName.new(dependency, cached_cookbook).to_s)
        end

        true
      end

      # Determines if the location is well formed and points to an accessible location
      #
      # @return [Boolean]
      def valid?
        true
      end

      def to_hash
        { type: self.class.location_key }
      end

      def to_json(options = {})
        JSON.pretty_generate(to_hash, options)
      end
    end

    class ScmLocation < Location::Base; end
  end
end

Dir["#{File.dirname(__FILE__)}/locations/*.rb"].sort.each do |path|
  require_relative "locations/#{File.basename(path, '.rb')}"
end
