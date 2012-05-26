module KnifeCookbookDependencies
  class Cookbook
    class Path

      include KCD::Cookbook::Common::Path
      include KCD::Cookbook::Common::Prepare

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

      def download(show_output)
      end

      def identifier
        cookbook.local_path
      end

    end
  end
end
