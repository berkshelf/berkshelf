require 'chef/knife'
require 'kcd'

module KnifeCookbookDependencies
  class CookbookDependenciesClean < Chef::Knife
    banner "knife cookbook dependencies clean"

    def run
      ui.info 'Cleaning up...'
      ::KCD.ui = ui

      ::KCD.clean
    end
  end
  
  class CookbookDepsClean < CookbookDependenciesClean
    banner "knife cookbook deps clean"
  end
end
