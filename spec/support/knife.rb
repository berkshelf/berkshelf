require 'chef/config'

module Berkshelf
  module RSpec
    module Knife
      class << self
        def load_knife_config(path)
          if File.exist?(path)
            ::Chef::Config.from_file(path)
            ENV["CHEF_CONFIG"] = path
          else
            raise "Cannot continue; '#{path}' must exist and have testing credentials." unless ENV['CI']
          end
        end
      end
    end
  end
end
