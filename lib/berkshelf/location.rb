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
            raise InternalError, "Only one location key (#{Berkshelf::Dependency.location_keys.keys.join(', ')}) may be specified. You gave #{location_keys.join(', ')}."
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

        # Returns an array where the first element is string representing the best version
        # for the given constraint and the second element is the URI to where the corresponding
        # version of the Cookbook can be downloaded from
        #
        # @example:
        #   constraint = Solve::Constraint.new('~> 0.101.2')
        #   versions = {
        #     '1.0.0' => 'http://cookbooks.opscode.com/api/v1/cookbooks/nginx/versions/1_0_0',
        #     '2.0.0' => 'http://cookbooks.opscode.com/api/v1/cookbooks/nginx/versions/2_0_0'
        #   }
        #
        #   subject.solve_for_constraint(versions, constraint) =>
        #     [ '2.0.0', 'http://cookbooks.opscode.com/api/v1/cookbooks/nginx/versions/2_0_0' ]
        #
        # @param [String, Solve::Constraint] constraint
        #   version constraint to solve for
        #
        # @param [Hash] versions
        #   a hash where the keys are a string representing a cookbook version and the values
        #   are the download URL for the cookbook version.
        #
        # @return [Array, nil]
        def solve_for_constraint(constraint, versions)
          version = Solve::Solver.satisfy_best(constraint, versions.keys).to_s

          [ version, versions[version] ]
        rescue Solve::Errors::NoSolutionError
          nil
        end
      end

      attr_reader :dependency

      # @param [Berkshelf::Dependency] dependency
      # @param [Hash] options
      def initialize(dependency, options = {})
        @dependency = dependency
      end

      # @param [#to_s] destination
      #
      # @return [Berkshelf::CachedCookbook]
      def download(destination)
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
          raise CookbookValidationFailure.new(self, cached_cookbook)
        end

        unless dependency.name == cached_cookbook.cookbook_name
          Berkshelf.ui.warn(MismatchedCookbookName.new(self, cached_cookbook).to_s)
        end

        true
      end

      def to_hash
        {
          type: self.class.location_key
        }
      end

      def to_json(options = {})
        JSON.pretty_generate(to_hash, options)
      end
    end
  end
end

Dir["#{File.dirname(__FILE__)}/locations/*.rb"].sort.each do |path|
  require_relative "locations/#{File.basename(path, '.rb')}"
end
