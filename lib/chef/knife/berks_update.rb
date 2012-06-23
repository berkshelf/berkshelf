require 'chef/knife'
require 'chef/knife/berks_install'

module Berkshelf
  class BerksUpdate < BerksInstall
    deps do
      require 'berkshelf'
    end

    banner "knife berks update"

    alias :install_run :run

    def run
      ::Berkshelf.ui = ui

      Lockfile.remove!
      install_run
    rescue BerkshelfError => e
      Berkshelf.ui.fatal e
      exit e.status_code
    end
  end
end
