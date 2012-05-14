require 'dep_selector'
require 'zlib'
require 'archive/tar/minitar'
require 'chef/config'
require 'chef/knife/cookbook_site_download'

require 'knife_cookbook_dependencies/version'
require 'knife_cookbook_dependencies/shelf'
require 'knife_cookbook_dependencies/cookbook'
require 'knife_cookbook_dependencies/metacookbook'
require 'knife_cookbook_dependencies/dependency_reader'
require 'knife_cookbook_dependencies/dsl'
require 'knife_cookbook_dependencies/cookbookfile'
require 'knife_cookbook_dependencies/git'
require 'knife_cookbook_dependencies/error_messages'

module KnifeCookbookDependencies
  DEFAULT_FILENAME = 'Cookbookfile'
  COOKBOOKS_DIRECTORY = 'cookbooks'

  class << self
    attr_accessor :ui

    def shelf
      @shelf ||= KCD::Shelf.new
    end

    def clear_shelf!
      @shelf = nil
    end

    def ui
      @ui ||= Chef::Knife::UI.new(STDOUT, STDERR, STDIN, {})
    end

    def clean
      clear_shelf!
      FileUtils.rm_rf COOKBOOKS_DIRECTORY
    end
  end
end

# Alias for {KnifeCookbookDependencies}
KCD = KnifeCookbookDependencies
