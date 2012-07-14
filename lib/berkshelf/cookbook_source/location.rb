module Berkshelf
  class CookbookSource
    # @author Jamie Winsor <jamie@vialstudios.com>
    module Location
      OPSCODE_COMMUNITY_API = 'http://cookbooks.opscode.com/api/v1/cookbooks'.freeze
      
      module ClassMethods
        # Register the location key for the including source location with CookbookSource
        #
        # @param [Symbol] key
        def location_key(key)
          CookbookSource.add_location_key(key, self)
        end

        # Register a valid option or multiple options with the CookbookSource class
        #
        # @param [Symbol] opts
        def valid_options(*opts)
          Array(opts).each do |opt|
            CookbookSource.add_valid_option(opt)
          end
        end

        # Returns an array where the first element is string representing the best version
        # for the given constraint and the second element is the URI to where the corresponding
        # version of the Cookbook can be downloaded from
        #
        # @example:
        #   constraint = Solve::Constraint.new("~> 0.101.2")
        #   versions = { 
        #     "1.0.0" => "http://cookbooks.opscode.com/api/v1/cookbooks/nginx/versions/1_0_0",
        #     "2.0.0" => "http://cookbooks.opscode.com/api/v1/cookbooks/nginx/versions/2_0_0"
        #   }
        #
        #   subject.solve_for_constraint(versions, constraint) =>
        #     [ "2.0.0", "http://cookbooks.opscode.com/api/v1/cookbooks/nginx/versions/2_0_0" ]
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
          graph = Solve::Graph.new
          name = "none"

          versions.each do |version, uri|
            graph.artifacts(name, version)
          end

          graph.demands(name, constraint)
          result = Solve.it(graph)

          return nil if result.nil?

          version = result[name]

          [ version, versions[version] ]
        end
      end

      class << self
        def included(base)
          base.send :extend, ClassMethods
        end

        # Creates a new instance of a Class implementing Location with the given name and
        # constraint. Which Class to instantiated is determined by the values in the given
        # options Hash. Source Locations have an associated location_key registered with
        # CookbookSource. If your options Hash contains a key matching one of these location_keys
        # then the Class who registered that location_key will be instantiated. If you do not
        # provide an option with a matching location_key a SiteLocation class will be
        # instantiated.
        #
        # @example
        #   Location.init("nginx", ">= 0.0.0", git: "git://github.com/RiotGames/artifact-cookbook.git") =>
        #     instantiates a GitLocation
        #
        #   Location.init("nginx", ">= 0.0.0", path: "/Users/reset/code/nginx-cookbook") =>
        #     instantiates a PathLocation
        #
        #   Location.init("nginx", ">= 0.0.0", site: "http://cookbooks.opscode.com/api/v1/cookbooks") =>
        #     instantiates a SiteLocation
        #
        #   Location.init("nginx", ">= 0.0.0", chef_api: "https://api.opscode.com/organizations/vialstudios") =>
        #     instantiates a ChefAPILocation
        #
        #   Location.init("nginx", ">= 0.0.0") =>
        #     instantiates a SiteLocation
        #
        # @param [String] name
        # @param [String, Solve::Constraint] constraint
        # @param [Hash] options
        #
        # @return [SiteLocation, PathLocation, GitLocation, ChefAPILocation]
        def init(name, constraint, options = {})
          klass = klass_from_options(options)

          klass.new(name, constraint, options)
        end

        private

          def klass_from_options(options)
            location_keys = (options.keys & CookbookSource.location_keys.keys)
            if location_keys.length > 1
              location_keys.collect! { |opt| "'#{opt}'" }
              raise InternalError, "Only one location key (#{CookbookSource.location_keys.keys.join(', ')}) may be specified. You gave #{location_keys.join(', ')}."
            end

            if location_keys.empty?
              SiteLocation
            else
              CookbookSource.location_keys[location_keys.first]
            end
          end
      end

      attr_reader :name
      attr_reader :version_constraint

      # @param [#to_s] name
      # @param [Solve::Constraint] version_constraint
      # @param [Hash] options
      def initialize(name, version_constraint, options = {})
        @name = name
        @version_constraint = version_constraint
        @downloaded_status = false
      end

      # @param [#to_s] destination
      #
      # @return [Berkshelf::CachedCookbook]
      def download(destination)
        raise AbstractFunction
      end

      # @return [Boolean]
      def downloaded?
        @downloaded_status
      end

      # Ensures that the given CachedCookbook satisfies the constraint
      #
      # @param [CachedCookbook] cached_cookbook
      #
      # @raise [ConstraintNotSatisfied] if the CachedCookbook does not satisfy the version constraint of
      #   this instance of Location.
      #
      # @return [Boolean]
      def validate_cached(cached_cookbook)
        unless version_constraint.satisfies?(cached_cookbook.version)
          raise ConstraintNotSatisfied, "A cookbook satisfying '#{name}' (#{version_constraint}) not found at #{self}"
        end

        true
      end

      private

        def set_downloaded_status(state)
          @downloaded_status = state
        end
    end
  end
end
