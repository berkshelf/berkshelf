require 'dep_selector'
require 'zlib'
require 'archive/tar/minitar'

require 'kcd/version'
require 'kcd/shelf'
require 'kcd/cookbook'
require 'kcd/metacookbook'
require 'kcd/dependency_reader'
require 'kcd/dsl'
require 'kcd/cookbookfile'
require 'kcd/lockfile'
require 'kcd/git'
require 'kcd/error_messages'

module KnifeCookbookDependencies
  DEFAULT_FILENAME = 'Cookbookfile'
  COOKBOOKS_DIRECTORY = 'cookbooks'

  autoload :KnifeUtils, 'kcd/knife_utils'

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
