module KnifeCookbookDependencies
  class Cookbook
    class Path

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

      def full_path
        File.join(cookbook.unpacked_cookbook_path, cookbook.name)
      end

      def clean(location)
        FileUtils.rm_rf location
        FileUtils.rm_f cookbook.download_filename
      end

    end
  end
end
