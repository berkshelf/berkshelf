require 'berkshelf/api'

module Berkshelf
  module RSpec
    module BerksAPIServer
      class << self
        def clear_cache
          Berkshelf::API::CacheManager.instance.clear
        end

        def instance
          Berkshelf::API::Application.instance
        end

        def start
          Berkshelf::API::Application.run!(log_location: "/dev/null")
        end

        def stop
          instance.shutdown
        end
      end

      def berks_dependency(name, version, options = {})
        options[:platforms] ||= Hash.new
        options[:dependencies] ||= Hash.new
        cookbook = Berkshelf::API::RemoteCookbook.new(name, version,
          Berkshelf::API::CacheBuilder::Worker::Opscode.worker_type, Berkshelf::API::SiteConnector::Opscode::V1_API)
        metadata = Ridley::Chef::Cookbook::Metadata.new
        options[:platforms].each { |name, version| metadata.supports(name, version) }
        options[:dependencies].each { |name, constraint| metadata.depends(name, constraint) }
        cache_manager.add(cookbook, metadata)
      end

      private

        def cache_manager
          Berkshelf::API::CacheManager.instance
        end
    end
  end
end
