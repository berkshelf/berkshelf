module KnifeCookbookDependencies
  class Cookbook
    class Download

      attr_reader :cookbook

      def initialize(args, cookbook)
        @version = args[1]
        @cookbook = cookbook
      end

      def prepare
        cookbook.add_version_constraint(@version)
      end

      def download(show_output)
        FileUtils.mkdir_p KCD::TMP_DIRECTORY
        csd = Chef::Knife::CookbookSiteDownload.new([cookbook.name, cookbook.latest_constrained_version.to_s, "--file", cookbook.download_filename])

        output = ''
        cookbook.rescue_404 do
          output = KCD::KnifeUtils.capture_knife_output(csd)
        end

        if show_output
          output.split(/\r?\n/).each { |x| KCD.ui.info(x) }
        end
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
