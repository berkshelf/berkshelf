require 'vagrant'
require 'berkshelf'

module Berkshelf
  # @author Jamie Winsor <jamie@vialstudios.com>
  # @author Andrew Garson <andrew.garson@gmail.com>
  module Vagrant
    module Action
      autoload :Install, 'berkshelf/vagrant/action/install'
      autoload :Upload, 'berkshelf/vagrant/action/upload'
      autoload :Clean, 'berkshelf/vagrant/action/clean'
      autoload :SetFormatter, 'berkshelf/vagrant/action/set_formatter'
    end

    autoload :Config, 'berkshelf/vagrant/config'

    class << self
      # @param [Vagrant::Action::Environment] env
      def shelf_for(env)
        File.join(Berkshelf.berkshelf_path, "vagrant", env[:global_config].vm.host_name)
      end

      # @param [Symbol] shortcut
      # @param [Vagrant::Config::Top] config
      #
      # @return [Array]
      def provisioners(shortcut, config)
        config.vm.provisioners.select { |prov| prov.shortcut == shortcut }
      end

      # Determine if the given instance of Vagrant::Config::Top contains a
      # chef_solo provisioner
      #
      # @param [Vagrant::Config::Top] config
      #
      # @return [Boolean]
      def chef_solo?(config)
        !provisioners(:chef_solo, config).empty?
      end

      # Determine if the given instance of Vagrant::Config::Top contains a
      # chef_client provisioner
      #
      # @param [Vagrant::Config::Top] config
      #
      # @return [Boolean]
      def chef_client?(config)
        !provisioners(:chef_client, config).empty?
      end
    end
  end
end

Vagrant.config_keys.register(:berkshelf) {
  Berkshelf::Vagrant::Config
}

install = Vagrant::Action::Builder.new {
  use Berkshelf::Vagrant::Action::SetFormatter
  use Berkshelf::Vagrant::Action::Install
}

upload = Vagrant::Action::Builder.new {
  use Berkshelf::Vagrant::Action::SetFormatter
  use Berkshelf::Vagrant::Action::Upload
}

clean = Vagrant::Action::Builder.new {
  use Berkshelf::Vagrant::Action::SetFormatter
  use Berkshelf::Vagrant::Action::Clean
}

Vagrant.actions[:provision].insert(Vagrant::Action::VM::Provision, install)
Vagrant.actions[:provision].insert(Vagrant::Action::VM::Provision, upload)
Vagrant.actions[:start].insert(Vagrant::Action::VM::Provision, install)
Vagrant.actions[:start].insert(Vagrant::Action::VM::Provision, upload)
Vagrant.actions[:destroy].insert(Vagrant::Action::VM::CleanMachineFolder, clean)
