require 'dep_selector'
require 'zlib'
require 'archive/tar/minitar'
require 'chef/config'
require 'chef/knife/cookbook_site_download'

require 'remy/version'
require 'remy/shelf'
require 'remy/cookbook'
require 'remy/metacookbook'
require 'remy/dependency_reader'
require 'remy/dsl'
require 'remy/cookbookfile'
require 'remy/git'

module Remy
  COOKBOOKS_DIRECTORY = 'cookbooks'

  class << self
    def shelf
      @shelf ||= Remy::Shelf.new
    end

    def clear_shelf!
      @shelf = nil
    end

    def ui=(ui)
      @ui = ui
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
