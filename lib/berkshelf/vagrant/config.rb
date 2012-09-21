module Berkshelf
  module Vagrant
    # @author Jamie Winsor <jamie@vialstudios.com>
    # @author Andrew Garson <andrew.garson@gmail.com>
    #
    # @note according to <http://vagrantup.com/v1/docs/extending/configuration.html> instance
    #   variables should not be instantiated with default values in the initializer of a Config file.
    #   Instead explicit getters which set and return the default value should be used.
    class Config < ::Vagrant::Config::Base
      # @return [String]
      #   path to a knife configuration file
      def config_path
        @config_path ||= Berkshelf::DEFAULT_CONFIG
      end

      # @param [String] value
      def config_path=(value)
        @config_path = File.expand_path(value)
      end

      # @return [String]
      #   path to the Berksfile to use with Vagrant
      def berksfile_path
        @berksfile_path ||= File.join(Dir.pwd, Berkshelf::DEFAULT_FILENAME)
      end

      # @param [String] value
      def berksfile_path=(value)
        @berksfile_path = File.expand_path(value)
      end

      # @return [String]
      #   A path to a client key on disk to use with the Chef Client provisioner to
      #   upload cookbooks installed by Berkshelf.
      attr_reader :client_key

      # @param [String] value
      def client_key=(value)
        @client_key = File.expand_path(value)
      end

      # @return [String]
      #   A client name (node_name) to use with the Chef Client provisioner to upload
      #   cookbooks installed by Berkshelf.
      attr_accessor :node_name

      # @return [Array<Symbol>]
      #   cookbooks in all other groups except for these will be installed
      #   and copied to Vagrant's shelf
      def except
        @except ||= Array.new
      end
      attr_writer :except

      # @return [Array<Symbol>]
      #   only cookbooks in these groups will be installed and copied to
      #   Vagrant's shelf
      def only
        @only ||= Array.new
      end
      attr_writer :only

      # @return [Boolean]
      #   should connections to a Chef API use SSL verification
      def ssl_verify
        @ssl_verify ||= true
      end
      attr_writer :ssl_verify

      def validate(env, errors)
        if !except.empty? && !only.empty?
          errors.add("A value for berkshelf.empty and berkshelf.only cannot both be defined.")
        end

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
