require 'chozo/config'

module Berkshelf
  # @author Justin Campbell <justin@justincampbell.me>
  # @author Jamie Winsor <jamie@vialstudios.com>
  class Config < Chozo::Config::JSON
    FILENAME = "config.json".freeze

    class << self
      # @return [String, nil]
      #   the contents of the file
      def file
        File.read(path) if File.exists?(path)
      end

      # @return [Config]
      def instance
        @instance ||= if file
          from_json file
        else
          new
        end
      end

      # @return [String]
      def path
        File.join(Berkshelf.berkshelf_path, FILENAME)
      end

      # @return [String]
      def chef_config_path
        @chef_config_path ||= File.expand_path(ENV["BERKSHELF_CHEF_CONFIG"] || "~/.chef/knife.rb")
      end

      # @param [String] value
      def chef_config_path=(value)
        @chef_config = nil
        @chef_config_path = value
      end

      # @return [Chef::Config]
      def chef_config
        @chef_config ||= begin
          Chef::Config.from_file(File.expand_path(chef_config_path))
          Chef::Config
        rescue
          Chef::Config
        end
      end
    end

    # @param [String] path
    # @param [Hash] options
    #   @see {Chozo::Config::JSON}
    def initialize(path = self.class.path, options = {})
      super(path, options)
    end

    attribute 'vagrant.chef.chef_server_url',
      type: String,
      default: chef_config[:chef_server_url]
    attribute 'vagrant.chef.validation_client_name',
      type: String,
      default: chef_config[:validation_client_name]
    attribute 'vagrant.chef.validation_key_path',
      type: String,
      default: chef_config[:validation_key]
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
      default: true
    attribute 'vagrant.vm.network.hostonly',
      type: String,
      default: '33.33.33.10'
    attribute 'vagrant.vm.provision',
      type: String,
      default: 'chef_solo'
  end
end
