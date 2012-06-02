require 'chef/knife'
require 'kcd'

module KnifeCookbookDependencies
  class CookbookDependenciesInstall < Chef::Knife
    banner "knife cookbook dependencies install (options)"

    option :without,
      :short => "-W WITHOUT",
      :long => "--without WITHOUT",
      :description => "Exclude cookbooks that are in these groups"

    def run
      ::KCD.ui = ui
      cookbook_file = ::KCD::Cookbookfile.from_file(File.join(Dir.pwd, "Cookbookfile"))
      cookbook_file.process_install(config)
    rescue CookbookfileNotFound => e
      KCD.ui.fatal e
      exit e.status_code
    rescue DownloadFailure => e
      KCD.ui.fatal e.message
      exit e.status_code
    end
  end
  
  class CookbookDepsInstall < CookbookDependenciesInstall
    banner "knife cookbook deps install (options)"
  end
end
