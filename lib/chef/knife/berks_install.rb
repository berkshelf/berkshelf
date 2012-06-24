require 'chef/knife'

module Berkshelf
  class BerksInstall < Chef::Knife
    deps do
      require 'berkshelf'
    end
    
    banner "knife berks install (options)"

    option :shims,
      short: "-s",
      long: "--shims",
      description: "Create a directory of shims pointing to Cookbook Versions.",
      boolean: true
    option :without,
      short: "-W WITHOUT",
      long: "--without WITHOUT",
      description: "Exclude cookbooks that are in these groups",
      proc: lambda { |w| w.split(",") },
      default: Array.new
    def run
      ::Berkshelf.ui = ui
      # JW TODO: replace knife with Thor bin. Opt parsing here isn't my favorite.
      if config[:shims]
        config[:shims] = shims_path
      end

      cookbook_file = ::Berkshelf::Berksfile.from_file(File.join(Dir.pwd, Berkshelf::DEFAULT_FILENAME))
      cookbook_file.install(config)
    rescue BerkshelfError => e
      Berkshelf.ui.fatal e
      exit e.status_code
    end

    private

      def shims_path
        File.join(Dir.pwd, "cookbooks")
      end
  end
end
