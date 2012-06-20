require 'chef/knife'

module KnifeCookbookDependencies
  class CookbookDependenciesClean < Chef::Knife
    deps do
      require 'kcd'
    end
    
    banner "knife cookbook dependencies clean"

    def run
      ui.info 'Cleaning up...'
      ::KCD.ui = ui

      ::KCD.clean
    rescue KCDError => e
      KCD.ui.fatal e
      exit e.status_code
    end
  end
end
