module KnifeCookbookDependencies
  class Cookbook
    class Path

      include KCD::Cookbook::Common::Path

      attr_reader :cookbook

      def initialize(args, cookbook)
        @cookbook = cookbook
        @options  = cookbook.options

        unless @options[:path]
          # FIXME make pretty
          raise ArgumentError, "no path specified"
        end

        @options[:path] = File.expand_path(@options[:path]) 
      end

      def prepare
        cookbook.add_version_constraint("= #{cookbook.version_from_metadata.to_s}")
      end

      def download(show_output)
      end

    end
  end
end
