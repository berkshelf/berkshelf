require 'berkshelf/core_ext'
require 'berkshelf/errors'
require 'chef/knife'
require 'chef/rest'
require 'chef/platform'
require 'chef/cookbook/metadata'

Chef::Config[:cache_options][:path] = Dir.mktmpdir

module Berkshelf
  DEFAULT_STORE_PATH = File.expand_path("~/.bookshelf").freeze
  DEFAULT_FILENAME = 'Cookbookfile'.freeze

  autoload :InitGenerator, 'berkshelf/init_generator'
  autoload :CookbookSource, 'berkshelf/cookbook_source'
  autoload :CookbookStore, 'berkshelf/cookbook_store'
  autoload :CachedCookbook, 'berkshelf/cached_cookbook'
  autoload :TXResult, 'berkshelf/tx_result'
  autoload :TXResultSet, 'berkshelf/tx_result_set'
  autoload :Downloader, 'berkshelf/downloader'
  autoload :Uploader, 'berkshelf/uploader'
  autoload :Resolver, 'berkshelf/resolver'

  class << self
    attr_accessor :ui
    attr_accessor :cookbook_store
    attr_accessor :downloader

    def root
      File.join(File.dirname(__FILE__), '..')
    end

    def ui
      @ui ||= Chef::Knife::UI.new(null_stream, null_stream, STDIN, {})
    end

    # Returns the filepath to the location Cookbooks will be downloaded to
    # or uploaded from. By default this is '~/.bookshelf' but can be overridden
    # by specifying a value for the ENV variable 'BOOKSHELF_PATH'.
    # 
    # @return [Stirng]
    def bookshelf_path
      ENV["BOOKSHELF_PATH"] || DEFAULT_STORE_PATH
    end

    def cookbook_store
      @cookbook_store ||= CookbookStore.new(bookshelf_path)
    end

    def downloader
      @downloader ||= Downloader.new(cookbook_store)
    end

    # Ascend the directory structure from the given path to find a
    # metadata.rb file of a Chef Cookbook. If no metadata.rb file
    # was found, nil is returned.
    #
    # @return [Pathname] 
    #   path to metadata.rb 
    def find_metadata(path = Dir.pwd)
      path = Pathname.new(path)
      path.ascend do |potential_root|
        if potential_root.entries.collect(&:to_s).include?('metadata.rb')
          return potential_root.join('metadata.rb')
        end
      end
    end

    private

      def null_stream
        @null ||= begin
          strm = STDOUT.clone
          strm.reopen(RbConfig::CONFIG['host_os'] =~ /mswin|mingw/ ? 'NUL:' : '/dev/null')
          strm.sync = true
          strm
        end
      end
  end
end

require 'dep_selector'
require 'zlib'
require 'archive/tar/minitar'

require 'berkshelf/version'
require 'berkshelf/dsl'
require 'berkshelf/cookbookfile'
require 'berkshelf/lockfile'
require 'berkshelf/git'
