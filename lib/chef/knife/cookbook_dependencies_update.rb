require 'chef/knife'

module KnifeCookbookDependencies
  class CookbookDependenciesUpdate < CookbookDependenciesInstall
    deps do
      require 'kcd'
    end

    banner "knife cookbook dependencies update"

    alias :install_run :run

    def run
      ::KCD.ui = ui

      Lockfile.remove!
      install_run
    rescue KCDError => e
      KCD.ui.fatal e
      exit e.status_code
    end
  end
  
  class CookbookDepsUpdate < CookbookDependenciesUpdate
    banner "knife cookbook deps update"
  end
end
