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
  autoload :Downloader, 'kcd/downloader'

  class << self
    attr_accessor :ui

    def root
      File.join(File.dirname(__FILE__), '..')
    end

    def shelf
      @shelf ||= KCD::Shelf.new
    end

    def downloader
      @downloader ||= KCD::Downloader.new(TMP_DIRECTORY)
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

    # Ascend the directory structure from the given path to find a
    # metadata.rb file of a Chef Cookbook. If no metadata.rb file
    # was found, nil is returned.
    #
    # @returns[Pathname] 
    #   path to metadata.rb 
    def find_metadata(path = Dir.pwd)
      path = Pathname.new(path)
      path.ascend do |potential_root|
        if potential_root.entries.collect(&:to_s).include?('metadata.rb')
          return potential_root.join('metadata.rb')
        end
      end
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
