require 'chef/rest'
require 'chef/cookbook_version'

module KnifeCookbookDependencies
  module RSpec
    module ChefAPI
      def purge_cookbook(name, version)
        rest.delete_rest("cookbooks/#{name}/#{version}?purge=true")
      rescue Net::HTTPServerException => e
        raise unless e.to_s =~ /^404/
      end

      def server_has_cookbook?(name, version)
        rest.get_rest("cookbooks/#{name}/#{version}")
        true
      rescue Net::HTTPServerException => e
        false
      end

      private

        def rest
          quietly { Chef::REST.new(Chef::Config[:chef_server_url]) }
        end
    end
  end
end
