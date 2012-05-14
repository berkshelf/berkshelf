require 'chef/knife'
require 'kcd'

module KnifeCookbookDependencies
  class CookbookDependenciesInstall < Chef::Knife
    banner "knife cookbook dependencies install"

    def run
      ui.info 'Reading Cookbookfile'
      ::KCD.ui = ui
      ::KCD::Cookbookfile.process_install
    end
  end
  
  class CookbookDepsInstall < CookbookDependenciesInstall
    banner "knife cookbook deps install"
  end
end
