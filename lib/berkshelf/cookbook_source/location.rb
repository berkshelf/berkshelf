module Berkshelf
  class CookbookSource
    # @author Jamie Winsor <jamie@vialstudios.com>
    module Location
      module ClassMethods
        # Register the location key for the including source location with CookbookSource
        #
        # @param [Symbol] key
        def location_key(key)
          CookbookSource.add_location_key(key)
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
        # for the given constraint and the second element is the URI to where the corrosponding
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
        # @param [Solve::Constraint] constraint
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
        raise NotImplementedError, "Function must be implemented on includer"
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
