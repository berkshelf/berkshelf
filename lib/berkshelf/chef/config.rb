require 'berkshelf/mixin'
require 'mixlib/config'

module Berkshelf::Chef
  # @author Jamie Winsor <reset@riotgames.com>
  #
  # Inspired by and a dependency-free replacement for {https://raw.github.com/opscode/chef/11.4.0/lib/chef/config.rb}
  class Config
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

    cache_options           path: Dir.mktmpdir
  end
end
