require 'chef/knife'
require 'knife_cookbook_dependencies'

module KnifeCookbookDependencies
  class CookbookDependenciesInstall < Chef::Knife
    banner "knife cookbook dependencies install"

    def run
      ui.info 'Reading Cookbookfile'
      ::KnifeCookbookDependencies.ui = ui
      ::KnifeCookbookDependencies::Cookbookfile.process_install
    end
  end
end
