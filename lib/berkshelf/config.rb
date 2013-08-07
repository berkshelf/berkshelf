require 'buff/config/json'

module Berkshelf
  class Config < Buff::Config::JSON
    class << self
      # @return [String]
      def store_location
        File.join(Berkshelf.berkshelf_path, 'config.json')
      end

      # @return [String]
      def local_location
        ENV['BERKSHELF_CONFIG'] || File.join('.', '.berkshelf', 'config.json')
      end

      # @return [String]
      def path
        path = File.exists?(local_location) ? local_location : store_location
        File.expand_path(path)
      end

      # @param [Berkshelf::Config] config
      def set_config(config)
        @instance = config
      end

      # @param [String] new_path
      def set_path(new_path)
        @instance = nil
      end

      # @return [String, nil]
      #   the contents of the file
      def file
        File.read(path) if File.exists?(path)
      end

      # Instantiate and return or just return the currently instantiated Berkshelf
      # configuration
      #
      # @return [Config]
      def instance
        @instance ||= if file
          from_json file
        else
          new
        end
      end

      # Reload the currently instantiated Berkshelf configuration
      #
      # @return [Config]
      def reload
        @instance = nil
        self.instance
      end
    end

    # @param [String] path
    # @param [Hash] options
    #   @see {Buff::Config::JSON}
    def initialize(path = self.class.path, options = {})
      super(path, options)
    end

    attribute 'chef_servers',
      type: Hash,
      default: {
        default: {
          chef_server_url: Berkshelf.chef_config.chef_server_url,
          validation_client_name: Berkshelf.chef_config.validation_client_name,
          validation_key_path: Berkshelf.chef_config.validation_key,
          client_key: Berkshelf.chef_config.client_key,
          node_name: Berkshelf.chef_config.node_name
        }
      }
    attribute 'cookbook.copyright',
      type: String,
      default: Berkshelf.chef_config.cookbook_copyright
    attribute 'cookbook.email',
      type: String,
      default: Berkshelf.chef_config.cookbook_email
    attribute 'cookbook.license',
      type: String,
      default: Berkshelf.chef_config.cookbook_license
    attribute 'allowed_licenses',
      type: Array,
      default: Array.new
    attribute 'raise_license_exception',
      type: Boolean,
      default: false
    attribute 'vagrant.vm.box',
      type: String,
      default: 'opscode_ubuntu-12.04_provisionerless',
      required: true
    attribute 'vagrant.vm.box_url',
      type: String,
      default: 'https://opscode-vm-bento.s3.amazonaws.com/vagrant/opscode_ubuntu-12.04_provisionerless.box',
      required: true
    attribute 'vagrant.vm.forward_port',
      type: Hash,
      default: Hash.new
    attribute 'vagrant.vm.network.bridged',
      type: Boolean,
      default: false
    attribute 'vagrant.vm.network.hostonly',
      type: String,
      default: '33.33.33.10'
    attribute 'vagrant.vm.provision',
      type: String,
      default: 'chef_solo'
    attribute 'vagrant.omnibus.enabled',
      type: Boolean,
      default: true
    attribute 'vagrant.omnibus.version',
      type: String,
      default: 'latest'
    attribute 'ssl.verify',
      type: Boolean,
      default: true,
      required: true

    # @return [Hash]
    def chef
      chef_server(:default)
    end

    # @param [#to_sym] name
    #
    # @return [Hash]
    def chef_server(name)
      chef_servers[name.to_sym]
    end

    def whitelist_assign(new_attributes = {})
      # @todo remove for Berkshelf 4.0
      if chef_attributes = new_attributes.delete("chef")
        Berkshelf.ui.deprecated "The Berkshelf configuration file now allows you to configure more than one Chef Server."
        Berkshelf.ui.deprecated "See https://github.com/RiotGames/berkshelf/wiki/3.0-Config-file-changes for more details."
        Berkshelf.ui.deprecated "Configuring a single Chef server will be deprecated in a future version of Berkshelf."
        Berkshelf.ui.deprecated "Update your configuration file at '#{path}' to squelch this message."

        new_attributes["chef_servers"] ||= Hash.new
        new_attributes["chef_servers"]["default"] = chef_attributes
      end

      super(new_attributes)
    end
  end
end
