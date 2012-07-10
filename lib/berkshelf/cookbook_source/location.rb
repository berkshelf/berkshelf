module Berkshelf
  class CookbookSource
    # @author Jamie Winsor <jamie@vialstudios.com>
    module Location
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
