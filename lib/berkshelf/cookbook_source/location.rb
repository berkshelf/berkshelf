module Berkshelf
  class CookbookSource
    # @author Jamie Winsor <jamie@vialstudios.com>
    module Location
      attr_reader :name
      attr_reader :version_constraint

      # @param [#to_s] name
      def initialize(name, version_constraint)
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

      # Ensures that the given CachedCookbook satisfies the constraint and contains a valid
      # cookbook.
      #
      # @param [CachedCookbook] cached_cookbook
      #
      # @raise [ConstraintNotSatisfied] if the CachedCookbook does not satisfy the version constraint of
      #   this instance of Location.
      #   contain a cookbook that satisfies the given version constraint of this instance of
      #   CookbookSource.
      #
      # @return [Boolean]
      def validate_cached(cached_cookbook)
        unless version_constraint.include?(cached_cookbook.version)
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
