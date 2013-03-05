require 'socket'
require 'tmpdir'
require 'berkshelf/mixin'
require 'mixlib/config'

module Berkshelf::Chef
  # @author Jamie Winsor <reset@riotgames.com>
  #
  # Inspired by and a dependency-free replacement for {https://raw.github.com/opscode/chef/11.4.0/lib/chef/config.rb}
  class Config
    # List taken from: http://wiki.opscode.com/display/chef/Chef+Configuration+Settings
    # Listed in order of preferred preference
    KNIFE_LOCATIONS = [
      './.chef/knife.rb',
      '~/.chef/knife.rb',
      '/etc/chef/solo.rb',
      '/etc/chef/client.rb'
    ].freeze

    class << self
      # Load and return a Chef::Config for Berkshelf. The location of the configuration to be loaded
      # can be configured by setting a value for {Berkshelf::Chef::Config.path=}
      #
      # @return [Berkshelf::Chef::Config]
      def instance
        @instance ||= begin
          self.from_file(File.expand_path(path))
          self
        rescue
          self
        end
      end

      # Return the most sensible path to the Chef configuration file. This can be configured by setting a
      # value for the 'BERKSHELF_CHEF_CONFIG' environment variable.
      #
      # If no value is set for the environment variable then a search will begin for a configuration at these paths
      # in this order:
      #
      # * './chef/knife.rb'
      # * '~/.chef/knife.rb',
      # * '/etc/chef/solo.rb'
      # * '/etc/chef/client.rb'
      #
      # @return [String, nil]
      def path
        @path ||= begin
          possibles = KNIFE_LOCATIONS.dup

          unless ENV['BERKSHELF_CHEF_CONFIG'].nil?
            possibles.unshift(ENV['BERKSHELF_CHEF_CONFIG'])
          end

          location = possibles.find do |location|
            File.exists?(File.expand_path(location))
          end
          location ||= "~/.chef/knife.rb"

          File.expand_path(location)
        end
      end

      # Set the path the Chef configuration can be found in
      #
      # @param [String] value
      def path=(value)
        @instance = nil
        @path     = value
      end
    end

    extend Berkshelf::Mixin::PathHelpers
    extend Mixlib::Config

    node_name               Socket.gethostname
    chef_server_url         "http://localhost:4000"
    client_key              platform_specific_path("/etc/chef/client.pem")
    validation_key          platform_specific_path("/etc/chef/validation.pem")
    validation_client_name  "chef-validator"

    cookbook_copyright      "YOUR_NAME"
    cookbook_email          "YOUR_EMAIL"
    cookbook_license        "reserved"

    knife                   Hash.new

    # history: prior to Chef 11, the cache implementation was based on
    # moneta and configured via cache_options[:path]. Knife configs
    # generated with Chef 11 will have `syntax_check_cache_path`, but older
    # configs will have `cache_options[:path]`. `cache_options` is marked
    # deprecated in chef/config.rb but doesn't currently trigger a warning.
    # See also: CHEF-3715
    syntax_check_cache_path Dir.mktmpdir
    cache_options           path: syntax_check_cache_path
  end
end
