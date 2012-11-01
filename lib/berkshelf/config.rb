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
    end

    def initialize(path = self.class.path, options = {})
      super(path, options)
    end

    attribute 'vagrant.chef.chef_server_url',
      type: String
    attribute 'vagrant.chef.validation_client_name',
      type: String
    attribute 'vagrant.chef.validation_key_path',
      type: String
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
