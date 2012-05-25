module KnifeCookbookDependencies
  class Cookbook
    class Path
      def initialize(args, cookbook)
        @options = cookbook.options

        unless @options[:path]
          # FIXME make pretty
          raise ArgumentError, "no path specified"
        end

        @options[:path] = File.expand_path(@options[:path]) 
        cookbook.add_version_constraint("= #{cookbook.version_from_metadata.to_s}")
      end
    end
  end
end
