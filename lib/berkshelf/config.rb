require 'chozo/config'

module Berkshelf
  # @author Justin Campbell <justin.campbell@riotgames.com>
  # @author Jamie Winsor <reset@riotgames.com>
  class Config < Chozo::Config::JSON
    FILENAME = "config.json".freeze

    class << self
      # @return [String]
      def path
        @path || File.join(Berkshelf.berkshelf_path, FILENAME)
      end

      # @param [String] new_path
      def path=(new_path)
        @path = File.expand_path(new_path)
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
    #   @see {Chozo::Config::JSON}
    def initialize(path = self.class.path, options = {})
      super(path, options)
    end

    attribute 'chef.chef_server_url',
      type: String,
      default: Berkshelf::Chef::Config.instance[:chef_server_url]
    attribute 'chef.validation_client_name',
      type: String,
      default: Berkshelf::Chef::Config.instance[:validation_client_name]
    attribute 'chef.validation_key_path',
      type: String,
      default: Berkshelf::Chef::Config.instance[:validation_key]
    attribute 'chef.client_key',
      type: String,
      default: Berkshelf::Chef::Config.instance[:client_key]
    attribute 'chef.node_name',
      type: String,
      default: Berkshelf::Chef::Config.instance[:node_name]
    attribute 'cookbook.copyright',
      type: String,
      default: Berkshelf::Chef::Config.instance[:cookbook_copyright]
    attribute 'cookbook.email',
      type: String,
      default: Berkshelf::Chef::Config.instance[:cookbook_email]
    attribute 'cookbook.license',
      type: String,
      default: Berkshelf::Chef::Config.instance[:cookbook_license]
    attribute 'vagrant.vm.box',
      type: String,
      default: 'Berkshelf-CentOS-6.3-x86_64-minimal',
      required: true
    attribute 'vagrant.vm.box_url',
      type: String,
      default: 'https://dl.dropbox.com/u/31081437/Berkshelf-CentOS-6.3-x86_64-minimal.box',
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
    attribute 'ssl.verify',
      type: Boolean,
      default: true,
      required: true
  end
end
