require 'forwardable'
require 'pathname'
require 'zlib'
require 'archive/tar/minitar'
require 'solve'
require 'chef/knife'
require 'chef/rest'
require 'chef/platform'
require 'chef/cookbook/metadata'
require 'chef/cookbook_version'

require 'berkshelf/version'
require 'berkshelf/core_ext'
require 'berkshelf/errors'

Chef::Config[:cache_options][:path] = Dir.mktmpdir

module Berkshelf
  DEFAULT_CONFIG = File.expand_path(ENV["CHEF_CONFIG"] || "~/.chef/knife.rb")
  DEFAULT_STORE_PATH = File.expand_path("~/.berkshelf").freeze
  DEFAULT_FILENAME = 'Berksfile'.freeze

  autoload :Cli, 'berkshelf/cli'
  autoload :DSL, 'berkshelf/dsl'
  autoload :Git, 'berkshelf/git'
  autoload :Berksfile, 'berkshelf/berksfile'
  autoload :Lockfile, 'berkshelf/lockfile'
  autoload :BaseGenerator, 'berkshelf/base_generator'
  autoload :InitGenerator, 'berkshelf/init_generator'
  autoload :CookbookGenerator, 'berkshelf/cookbook_generator'
  autoload :CookbookSource, 'berkshelf/cookbook_source'
  autoload :CookbookStore, 'berkshelf/cookbook_store'
  autoload :CachedCookbook, 'berkshelf/cached_cookbook'
  autoload :Downloader, 'berkshelf/downloader'
  autoload :Uploader, 'berkshelf/uploader'
  autoload :Resolver, 'berkshelf/resolver'

  class << self
    attr_accessor :ui
    
    attr_writer :config_path
    attr_writer :cookbook_store

    def root
      @root ||= Pathname.new(File.expand_path('../', File.dirname(__FILE__)))
    end

    def ui
      @ui ||= Chef::Knife::UI.new(null_stream, null_stream, STDIN, {})
    end

    # Returns the filepath to the location Berskhelf will use for
    # storage; temp files will go here, Cookbooks will be downloaded
    # to or uploaded from here. By default this is '~/.berkshelf' but
    # can be overridden by specifying a value for the ENV variable
    # 'BERKSHELF_PATH'.
    # 
    # @return [String]
    def berkshelf_path
      ENV["BERKSHELF_PATH"] || DEFAULT_STORE_PATH
    end

    def tmp_dir
      File.join(berkshelf_path, "tmp")
    end

    def cookbooks_dir
      File.join(berkshelf_path, "cookbooks")
    end

    def cookbook_store
      @cookbook_store ||= CookbookStore.new(cookbooks_dir)
    end

    def config_path
      @config_path ||= DEFAULT_CONFIG
    end

    # Load the config found at the given path as the Chef::Config. If no path is specified
    # the value of Berkshelf.chef_config will be used.
    #
    # @param [String] path
    def load_config(path = config_path)
      Chef::Config.from_file(File.expand_path(path))
    rescue Errno::ENOENT
      raise KnifeConfigNotFound, "Attempted to load configuration from: '#{path}' but not found."
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

    # Get the appropriate Formatter object based on the formatter
    # classes that have been registered.
    #
    # @return [~Formatter]
    def formatter
      @formatter ||= (formatters.has_key?(@_format) ? formatters[@_format] : Formatters::HumanReadable).new
    end

    # Specify a formatter identifier
    #
    # @param [String] format
    #   which formatter to use
    #
    # @example Berkshelf.set_format "json"
    def set_format(format)
      @_format = format
      @formatter = nil
    end

    # Access the formatters map that links string symbols to Formatter
    # implementations
    #
    # @return [Hash]
    def formatters
      @formatters ||= {}
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

require 'berkshelf/formatters'
