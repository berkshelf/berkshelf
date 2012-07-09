require 'chef/config'

module Berkshelf
  module RSpec
    module Knife
      class << self
        def check_knife_rb
          knife_rb = File.join(Dir.pwd, "spec/knife.rb")

          if File.exist?(knife_rb)
            Chef::Config.from_file(knife_rb)
            ENV["CHEF_CONFIG"] = knife_rb
          else
            raise "Cannot continue; '#{knife_rb}' must exist and have testing credentials."
          end
        end
      end
    end
  end
end
