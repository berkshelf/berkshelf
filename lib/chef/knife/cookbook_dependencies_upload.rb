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

    option :freeze,
      :long => "--freeze",
      :description => "Freeze the uploaded cookbooks so that they cannot be overwritten"

    option :force,
      :long => "--force",
      :description => "Upload all cookbooks even if a frozen one exists on the target Chef Server"

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
