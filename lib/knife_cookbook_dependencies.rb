require 'kcd/core_ext'
require 'kcd/errors'
require 'chef/knife'
require 'chef/rest'
require 'chef/platform'
require 'chef/cookbook/metadata'

Chef::Config[:cache_options][:path] = Dir.mktmpdir

module KnifeCookbookDependencies
  DEFAULT_STORE_PATH = File.expand_path("~/.bookshelf").freeze
  DEFAULT_FILENAME = 'Cookbookfile'.freeze

  autoload :InitGenerator, 'kcd/init_generator'
  autoload :CookbookSource, 'kcd/cookbook_source'
  autoload :CookbookStore, 'kcd/cookbook_store'
  autoload :CachedCookbook, 'kcd/cached_cookbook'
  autoload :TXResult, 'kcd/tx_result'
  autoload :TXResultSet, 'kcd/tx_result_set'
  autoload :Downloader, 'kcd/downloader'
  autoload :Uploader, 'kcd/uploader'
  autoload :Resolver, 'kcd/resolver'

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

    def default_store_path
      ENV["BOOKSHELF_PATH"] || DEFAULT_STORE_PATH
    end

    def cookbook_store
      @cookbook_store ||= CookbookStore.new(default_store_path)
    end

    def downloader
      @downloader ||= Downloader.new(cookbook_store)
    end

    def clean
      Lockfile.remove!
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

# Alias for {KnifeCookbookDependencies}
KCD = KnifeCookbookDependencies

require 'dep_selector'
require 'zlib'
require 'archive/tar/minitar'

require 'kcd/version'
require 'kcd/dsl'
require 'kcd/cookbookfile'
require 'kcd/lockfile'
require 'kcd/git'
