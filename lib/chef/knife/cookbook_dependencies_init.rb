require 'chef/knife'

module KnifeCookbookDependencies
  class CookbookDependenciesInit < Chef::Knife
    deps do
      require 'kcd'
    end
    
    banner "knife cookbook dependencies init [PATH]"

    def run
      ::KCD.ui = ui
      config[:path] = File.expand_path(@name_args.first || Dir.pwd)

      if File.chef_cookbook?(config[:path])
        config[:chefignore] = true
        config[:metadata_entry] = true
      end

      generator = ::KCD::InitGenerator.new([], config)
      generator.invoke_all

      ::KCD.ui.info "Successfully initialized"
    rescue KCDError => e
      KCD.ui.fatal e
      exit e.status_code
    end
  end

  class CookbookDepsInit < CookbookDependenciesInit
    banner "knife cookbook deps init [PATH]"
  end
end
