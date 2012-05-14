require 'stringio'
require 'chef/config'
require 'knife_cookbook_dependencies/alias'

module KnifeCookbookDependencies
  module KnifeUtils
    def self.capture_knife_output(knife_obj)
      knife_obj.ui = Chef::Knife::UI.new(StringIO.new, StringIO.new, StringIO.new, { :format => :json })
      knife_obj.run
      knife_obj.ui.stdout.rewind
      knife_obj.ui.stdout.read
    end
  end
end
