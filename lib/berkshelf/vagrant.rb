require 'vagrant'
require 'berkshelf'

module Berkshelf
  # @author Jamie Winsor <jamie@vialstudios.com>
  # @author Andrew Garson <andrew.garson@gmail.com>
  module Vagrant
    autoload :Config, 'berkshelf/vagrant/config'
    autoload :Middleware, 'berkshelf/vagrant/middleware'

    class << self
      # @param [Vagrant::Action::Environment] env
      def shelf_for(env)
        File.join(Berkshelf.berkshelf_path, "vagrant", env[:global_config].vm.host_name)
      end

      # @param [String] msg
      # @param [Vagrant::Action::Environment] env
      def info(msg, env)
        env[:ui].info("[Berkshelf] #{msg}")
      end

      # @param [Symbol] shortcut
      # @param [Vagrant::Action::Environment] env
      #
      # @return [Array]
      def provisioners(shortcut, env)
        env[:global_config].vm.provisioners.select { |prov| prov.shortcut == shortcut }
      end

      # Determine if the given instance of Vagrant::Environment contains at least one
      # chef_solo provisioner
      #
      # @param [Vagrant::Action::Environment] env
      #
      # @return [Boolean]
      def chef_solo?(env)
        !provisioners(:chef_solo, env).empty?
      end
    end
  end
end

Vagrant.config_keys.register(:berkshelf) {
  Berkshelf::Vagrant::Config
}

berks = Vagrant::Action::Builder.new {
  use Berkshelf::Vagrant::Middleware
}

Vagrant.actions[:provision].insert(Vagrant::Action::VM::Provision, berks)
Vagrant.actions[:start].insert(Vagrant::Action::VM::Provision, berks)
