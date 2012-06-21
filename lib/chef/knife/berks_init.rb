require 'chef/knife'

module Berkshelf
  class BerksInit < Chef::Knife
    deps do
      require 'berkshelf'
    end
    
    banner "knife berks init [PATH]"

    def run
      ::Berkshelf.ui = ui
      config[:path] = File.expand_path(@name_args.first || Dir.pwd)

      if File.chef_cookbook?(config[:path])
        config[:chefignore] = true
        config[:metadata_entry] = true
      end

      generator = ::Berkshelf::InitGenerator.new([], config)
      generator.invoke_all

      ::Berkshelf.ui.info "Successfully initialized"
    rescue BerkshelfError => e
      Berkshelf.ui.fatal e
      exit e.status_code
    end
  end
end
