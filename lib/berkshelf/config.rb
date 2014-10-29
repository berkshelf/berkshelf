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
      super(path, options).tap do
        # Deprecation
        if !self.vagrant.omnibus.enabled.nil?
          Berkshelf.ui.warn "`vagrant.omnibus.enabled' is deprecated and " \
            "will be removed in a future release. Please remove the " \
            "`enabled' attribute from your Berkshelf config."
        end
        if !self.vagrant.vm.box_url.nil?
          Berkshelf.ui.warn "`vagrant.vm.box_url' is deprecated and " \
            "will be removed in a future release. Please remove the " \
            "`box_url' attribute from your Berkshelf config."
        end
      end
    end

    attribute 'chef.chef_server_url',
      type: String,
      default: Berkshelf.chef_config.chef_server_url
    attribute 'chef.validation_client_name',
      type: String,
      default: Berkshelf.chef_config.validation_client_name
    attribute 'chef.validation_key_path',
      type: String,
      default: Berkshelf.chef_config.validation_key
    attribute 'chef.client_key',
      type: String,
      default: Berkshelf.chef_config.client_key
    attribute 'chef.node_name',
      type: String,
      default: Berkshelf.chef_config.node_name
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
      type: Buff::Boolean,
      default: false
    attribute 'vagrant.vm.box',
      type: String,
      default: 'chef/ubuntu-14.04',
      required: true
    # @todo Deprecated, remove?
    attribute 'vagrant.vm.box_url',
      type: String,
      default: nil
    attribute 'vagrant.vm.forward_port',
      type: Hash,
      default: Hash.new
    attribute 'vagrant.vm.provision',
      type: String,
      default: 'chef_solo'
    # @todo Deprecated, remove. There's a really weird tri-state here where
    # nil is used to represent an unset value, just FYI
    attribute 'vagrant.omnibus.enabled',
      type: Buff::Boolean,
      default: nil
    attribute 'vagrant.omnibus.version',
      type: String,
      default: 'latest'
    attribute 'ssl.verify',
      type: Buff::Boolean,
      default: true,
      required: true
    attribute 'github',
      type: Array,
      default: [],
      required: false
  end
end
