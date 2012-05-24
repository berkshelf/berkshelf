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
      ::KCD::Cookbookfile.process_install(config[:without])
    rescue CookbookfileNotFound => e
      KCD.ui.fatal e
      exit e.status_code
    rescue RemoteCookbookNotFound => e
      KCD.ui.fatal e
      exit e.status_code
    end
  end
  
  class CookbookDepsInstall < CookbookDependenciesInstall
    banner "knife cookbook deps install (options)"
  end
end
