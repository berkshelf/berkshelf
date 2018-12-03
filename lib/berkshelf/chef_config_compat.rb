require "chef-config/config"
require "chef-config/workstation_config_loader"
require "socket" # FIXME: why?

module Berkshelf
  class ChefConfigCompat
    # Create a new Chef Config object.
    #
    # @param [#to_s] path
    #   the path to the configuration file
    # @param [Hash] options
    def initialize(path, options = {})
      ChefConfig::WorkstationConfigLoader.new(path).load
      ChefConfig::Config.merge!(options)
      ChefConfig::Config.export_proxies # Set proxy settings as environment variables
      ChefConfig::Config.init_openssl # setup openssl + fips mode
    end

    # Keep defaults that aren't in ChefConfig::Config
    def cookbook_copyright(*args, &block)
      ChefConfig::Config.cookbook_copyright(*args, &block) || "YOUR_NAME"
    end

    def cookbook_email(*args, &block)
      ChefConfig::Config.cookbook_email(*args, &block) || "YOUR_EMAIL"
    end

    def cookbook_license(*args, &block)
      ChefConfig::Config.cookbook_license(*args, &block) || "reserved"
    end

    # The configuration as a hash
    def to_hash
      ChefConfig::Config.save(true)
    end

    # Load from a file
    def self.from_file(file)
      new(file)
    end

    # Behave just like ChefConfig::Config in general
    def method_missing(name, *args, &block)
      ChefConfig::Config.send(name, *args, &block)
    end

    def respond_to_missing?(name)
      ChefConfig::Config.respond_to?(name)
    end
  end
end
