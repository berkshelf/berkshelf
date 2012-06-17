require 'chef/knife'
require 'kcd'

module KnifeCookbookDependencies
  class CookbookDependenciesUpload < Chef::Knife
    banner "knife cookbook dependencies upload (options)"

    option :without,
      :short => "-W WITHOUT",
      :long => "--without WITHOUT",
      :description => "Exclude cookbooks that are in these groups",
      :proc => lambda { |w| w.split(",") }

    def run
      ::KCD.ui = ui
      cookbook_file = ::KCD::Cookbookfile.from_file(File.join(Dir.pwd, "Cookbookfile"))
      cookbook_file.upload(Chef::Config[:server_url], :without => config[:without])
    rescue KCDError => e
      KCD.ui.fatal e
      exit e.status_code
    end
  end
  
  class CookbookDepsInstall < CookbookDependenciesInstall
    banner "knife cookbook deps upload (options)"
  end
end
