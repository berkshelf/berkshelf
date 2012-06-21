require 'chef/knife'

module Berkshelf
  class BerksInstall < Chef::Knife
    deps do
      require 'berkshelf'
    end
    
    banner "knife berks install (options)"

    option :without,
      :short => "-W WITHOUT",
      :long => "--without WITHOUT",
      :description => "Exclude cookbooks that are in these groups",
      :proc => lambda { |w| w.split(",") },
      :default => Array.new

    def run
      ::Berkshelf.ui = ui
      cookbook_file = ::Berkshelf::Berksfile.from_file(File.join(Dir.pwd, Berkshelf::DEFAULT_FILENAME))
      cookbook_file.install(config)
    rescue BerkshelfError => e
      Berkshelf.ui.fatal e
      exit e.status_code
    end
  end
end
