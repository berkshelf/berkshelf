require 'chef_zero/server'
require 'json'

module Berkshelf::RSpec
  module ChefServer
    PORT = 4000

    class << self
      attr_reader :server

      def clear_request_log
        @request_log = Array.new
      end

      def request_log
        @request_log ||= Array.new
      end

      def server_url
        @server && @server.url
      end

      def start(options = {})
        return @server if @server

        options = options.reverse_merge(port: PORT)
        options[:generate_real_keys] = false

        @server = ChefZero::Server.new(options)
        @server.start_background
        @server.on_response do |request, response|
          request_log << [ request, response ]
        end
        clear_request_log

        @server
      end

      def stop
        @server.stop if running?
      end

      def running?
        @server && @server.running?
      end

      def reset!
        @server && @server.clear_data
      end
    end

    def chef_server
      ChefServer.server
    end

    def chef_client(name, hash = {})
      load_data(:clients, name, hash)
    end

    def chef_cookbook(name, hash = {})
      chef_server.load_data({ 'cookbooks' => { name => hash }})
    end

    def chef_cookbooks
      chef_server.data_store.list(['cookbooks']).inject({}) do |hash, name|
        hash[name] = chef_server.data_store.list(['cookbooks', name])
        hash
      end
    end

    def chef_data_bag(name, hash = {})
      chef_server.load_data({ 'data' => { name => hash }})
    end

    def chef_environment(name, hash = {})
      load_data(:environments, name, hash)
    end

    def chef_environment_locks(name)
      JSON.parse(chef_server.data_store.get(['environments', name]))['cookbook_versions']
    rescue ChefZero::DataStore::DataNotFoundError
      {}
    end

    def chef_node(name, hash = {})
      load_data(:nodes, name, hash)
    end

    def chef_role(name, hash = {})
      load_data(:roles, name, hash)
    end

    private

      def load_data(key, name, hash)
        chef_server.load_data({ key.to_s => { name => JSON.generate(hash) }})
      end
  end
end
