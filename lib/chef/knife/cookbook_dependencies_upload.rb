require 'chef/knife'

module KnifeCookbookDependencies
  class CookbookDependenciesUpload < Chef::Knife
    deps do
      require 'kcd'
    end

    banner "knife cookbook dependencies upload (options)"

    option :without,
      :short => "-W WITHOUT",
      :long => "--without WITHOUT",
      :description => "Exclude cookbooks that are in these groups",
      :proc => lambda { |w| w.split(",") },
      :default => Array.new

    option :freeze,
      :long => "--freeze",
      :description => "Freeze the uploaded cookbooks so that they cannot be overwritten",
      :boolean => true,
      :default => false

    option :force,
      :long => "--force",
      :description => "Upload all cookbooks even if a frozen one exists on the target Chef Server",
      :boolean => true,
      :default => false

    def run
      ::KCD.ui = ui
      cookbook_file = ::KCD::Cookbookfile.from_file(File.join(Dir.pwd, "Cookbookfile"))
      cookbook_file.upload(Chef::Config[:server_url], config)
    rescue KCDError => e
      KCD.ui.fatal e
      exit e.status_code
    end
  end
  
  class CookbookDepsUpload < CookbookDependenciesUpload
    banner "knife cookbook deps upload (options)"
  end
end
