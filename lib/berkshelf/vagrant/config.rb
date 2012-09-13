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

      # @return [Array<Symbol>]
      #   groups to skip installing and copying in the Vagrantfile
      attr_accessor :without

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
    end
  end
end
