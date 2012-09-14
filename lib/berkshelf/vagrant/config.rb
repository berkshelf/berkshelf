module Berkshelf
  module Vagrant
    # @author Jamie Winsor <jamie@vialstudios.com>
    # @author Andrew Garson <andrew.garson@gmail.com>
    class Config < ::Vagrant::Config::Base
      # return [String]
      #   path to a knife configuration file
      attr_reader :config_path

      # @return [String]
      #   path to the Berksfile to use with Vagrant
      attr_reader :berksfile_path

      # @return [String]
      attr_reader :client_key

      # @return [Array<Symbol>]
      #   groups to skip installing and copying in the Vagrantfile
      attr_accessor :without

      # @return [String]
      attr_accessor :node_name

      def initialize
        @config_path = Berkshelf::DEFAULT_CONFIG
        @berksfile_path = File.join(Dir.pwd, Berkshelf::DEFAULT_FILENAME)
        @without = Array.new
      end

      def config_path=(value)
        @config_path = File.expand_path(value)
      end

      def berksfile_path=(value)
        @berksfile_path = File.expand_path(value)
      end

      def client_key=(value)
        @client_key = File.expand_path(value)
      end

      def validate(env, errors)
        if Berkshelf::Vagrant.chef_client?(env.config.global)
          if node_name.nil?
            errors.add("A value for berkshelf.node_name is required when using the chef_client provisioner.")
          end

          if client_key.nil?
            errors.add("A value for berkshelf.client_key is required when using the chef_client provisioner.")
          end
        end
      end
    end
  end
end
