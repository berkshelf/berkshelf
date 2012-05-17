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
    end
  end
  
  class CookbookDepsInstall < CookbookDependenciesInstall
    banner "knife cookbook deps install (options)"
  end
end
