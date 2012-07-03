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
      # @return [String]
      #   path to the downloaded source
      def download(destination)
        raise NotImplementedError, "Function must be implemented on includer"
      end

      # @return [Boolean]
      def downloaded?
        @downloaded_status
      end

      private

        def set_downloaded_status(state)
          @downloaded_status = state
        end

        # Ensures that the given path contains a Cookbook that satisfies the version constraint
        # of this instance of CookbookSource.
        #
        # @param [#to_s] path
        #   path to the downloaded Cookbook
        #
        # @raise [CookbookNotFound] if downloaded path does not contain a Cookbook or does not
        #   contain a cookbook that satisfies the given version constraint of this instance of
        #   CookbookSource.
        #
        # @return [Boolean]
        def validate_downloaded!(path)
          # do a validation
          true
        end
    end
  end
end
