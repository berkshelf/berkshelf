module Berkshelf
  module Vagrant
    # @author Jamie Winsor <reset@riotgames.com>
    # @author Andrew Garson <andrew.garson@gmail.com>
    class Config < ::Vagrant::Config::Base
      # @return [String]
      #   path to the Berksfile to use with Vagrant
      attr_reader :berksfile_path

      # @return [Array<Symbol>]
      #   only cookbooks in these groups will be installed and copied to
      #   Vagrant's shelf
      attr_accessor :only

      # @return [Array<Symbol>]
      #   cookbooks in all other groups except for these will be installed
      #   and copied to Vagrant's shelf
      attr_accessor :except

      def initialize
        @berksfile_path = File.join(Dir.pwd, Berkshelf::DEFAULT_FILENAME)
        @except         = Array.new
        @only           = Array.new
      end

      # @param [String] value
      def berksfile_path=(value)
        @berksfile_path = File.expand_path(value)
      end

      # @param [String] value
      def client_key=(value)
        @client_key = File.expand_path(value)
      end

      def validate(env, errors)
        if !except.empty? && !only.empty?
          errors.add("A value for berkshelf.empty and berkshelf.only cannot both be defined.")
        end

        if Berkshelf::Vagrant.chef_client?(env.config.global)
          if Berkshelf::Config.instance.chef.node_name.nil?
            errors.add("A configuration must be set for chef.node_name when using the chef_client provisioner. Run 'berks configure' or edit your configuration.")
          end

          if Berkshelf::Config.instance.chef.client_key.nil?
            errors.add("A configuration must be set for chef.client_key when using the chef_client provisioner. Run 'berks configure' or edit your configuration.")
          end
        end
      end
    end
  end
end
