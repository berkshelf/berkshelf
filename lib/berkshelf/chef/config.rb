require 'socket'

module Berkshelf
  module Chef
    class Config
      require 'berkshelf/mixin/config'
      include Berkshelf::Mixin::Config

      class << self
        private
          # Return the most sensible path to the Chef configuration file. This can
          # be configured by setting a value for the 'BERKSHELF_CHEF_CONFIG' environment
          # variable.
          #
          # @return [String, nil]
          def location
            possibles = []

            possibles << ENV['BERKSHELF_CHEF_CONFIG'] if ENV['BERKSHELF_CHEF_CONFIG']
            possibles << File.join(ENV['KNIFE_HOME'], 'knife.rb') if ENV['KNIFE_HOME']
            possibles << File.join(working_dir, 'knife.rb') if working_dir

            # Ascending search for .chef directory siblings
            Pathname.new(working_dir).ascend do |file|
              sibling_chef = File.join(file, '.chef')
              possibles << File.join(sibling_chef, 'knife.rb')
            end if working_dir

            possibles << File.join(ENV['HOME'], '.chef', 'knife.rb') if ENV['HOME']
            possibles.compact!

            location = possibles.find { |loc| File.exists?(File.expand_path(loc)) }

            File.expand_path(location) unless location.nil?
          end

          # The current working directory
          #
          # @return [String]
          def working_dir
            ENV['PWD'] || Dir.pwd
          end
      end

      default_option(:node_name,                Socket.gethostname)
      default_option(:chef_server_url,          'http://localhost:4000')
      default_option(:client_key,               platform_specific_path('/etc/chef/client.pem'))
      default_option(:validation_key,           platform_specific_path('/etc/chef/validation.pem'))
      default_option(:validation_client_name,   'chef-validator')

      default_option(:cookbook_copyright,       'YOUR_NAME')
      default_option(:cookbook_email,           'YOUR_EMAIL')
      default_option(:cookbook_license,         'reserved')

      default_option(:knife, {})

      # Prior to Chef 11, the cache implementation was based on
      # moneta and configured via cache_options[:path]. Knife configs
      # generated with Chef 11 will have `syntax_check_cache_path`, but older
      # configs will have `cache_options[:path]`. `cache_options` is marked
      # deprecated in chef/config.rb but doesn't currently trigger a warning.
      # See also: CHEF-3715
      default_option(:syntax_check_cache_path,  Dir.mktmpdir)
      default_option(:cache_options,            { path: defined?(syntax_check_cache_path) ? syntax_check_cache_path : Dir.mktmpdir })
    end
  end
end
