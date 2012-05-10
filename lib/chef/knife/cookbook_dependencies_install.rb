require 'chef/knife'
require 'knife_cookbook_dependencies'

module KnifeCookbookDependencies
  class CookbookDependenciesInstall < Chef::Knife
    banner "knife cookbook dependencies install (options)"

    option :without,
      :short => "-W",
      :long => "--without",
      :description => "Exclude cookbooks that are in these groups"

    def run
      ui.info 'Reading Cookbookfile'
      ::KnifeCookbookDependencies.ui = ui
      ::KnifeCookbookDependencies::Cookbookfile.process_install(config[:without])
    end
  end
  
  class CookbookDepsInstall < CookbookDependenciesInstall; end

end
