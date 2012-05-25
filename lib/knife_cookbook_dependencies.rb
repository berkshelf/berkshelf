require 'kcd/core_ext'
require 'kcd/errors'

module KnifeCookbookDependencies
  DEFAULT_FILENAME = 'Cookbookfile'.freeze
  COOKBOOKS_DIRECTORY = 'cookbooks'
  TMP_DIRECTORY = File.join(ENV['TMPDIR'] || ENV['TEMP'], 'knife_cookbook_dependencies')
  FileUtils.mkdir_p TMP_DIRECTORY

  autoload :KnifeUtils, 'kcd/knife_utils'
  autoload :InitGenerator, 'kcd/init_generator'
  autoload :CookbookSource, 'kcd/cookbook_source'

  class << self
    attr_accessor :ui

    def root
      File.join(File.dirname(__FILE__), '..')
    end

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
      Lockfile.remove!
      FileUtils.rm_rf COOKBOOKS_DIRECTORY
      FileUtils.rm_rf TMP_DIRECTORY
    end
  end
end

# Alias for {KnifeCookbookDependencies}
KCD = KnifeCookbookDependencies

require 'dep_selector'
require 'zlib'
require 'archive/tar/minitar'

require 'kcd/version'
require 'kcd/shelf'
require 'kcd/cookbook'
require 'kcd/metacookbook'
require 'kcd/dsl'
require 'kcd/cookbookfile'
require 'kcd/lockfile'
require 'kcd/git'
