require 'multi_json'

# Fix for Facter < 1.7.0 changing LANG to C
# https://github.com/puppetlabs/facter/commit/f77584f4
begin
  old_lang = ENV['LANG']
  require 'ridley'
ensure
  ENV['LANG'] = old_lang
end

require 'chozo/core_ext'
require 'active_support/core_ext'
require 'archive/tar/minitar'
require 'forwardable'
require 'hashie'
require 'pathname'
require 'solve'
require 'thor'
require 'tmpdir'
require 'uri'
require 'zlib'

require 'berkshelf/version'
require 'berkshelf/core_ext'
require 'berkshelf/errors'
require 'thor/monkies'

JSON.create_id = nil

module Berkshelf
  DEFAULT_FILENAME = 'Berksfile'.freeze

  autoload :BaseGenerator, 'berkshelf/base_generator'
  autoload :Berksfile, 'berkshelf/berksfile'
  autoload :CachedCookbook, 'berkshelf/cached_cookbook'
  autoload :Chef, 'berkshelf/chef'
  autoload :Cli, 'berkshelf/cli'
  autoload :CommunityREST, 'berkshelf/community_rest'
  autoload :Config, 'berkshelf/config'
  autoload :CookbookGenerator, 'berkshelf/cookbook_generator'
  autoload :CookbookSource, 'berkshelf/cookbook_source'
  autoload :CookbookStore, 'berkshelf/cookbook_store'
  autoload :Downloader, 'berkshelf/downloader'
  autoload :Git, 'berkshelf/git'
  autoload :InitGenerator, 'berkshelf/init_generator'
  autoload :Lockfile, 'berkshelf/lockfile'
  autoload :Mixin, 'berkshelf/mixin'
  autoload :Resolver, 'berkshelf/resolver'
  autoload :UI, 'berkshelf/ui'

  require 'berkshelf/location'

  class << self
    attr_accessor :ui

    attr_writer :cookbook_store

    # @return [Pathname]
    def root
      @root ||= Pathname.new(File.expand_path('../', File.dirname(__FILE__)))
    end

    # @return [::Thor::Shell::Color]
    def ui
      @ui ||= ::Thor::Shell::Color.new
    end

    # Returns the filepath to the location Berskhelf will use for
    # storage; temp files will go here, Cookbooks will be downloaded
    # to or uploaded from here. By default this is '~/.berkshelf' but
    # can be overridden by specifying a value for the ENV variable
    # 'BERKSHELF_PATH'.
    #
    # @return [String]
    def berkshelf_path
      ENV["BERKSHELF_PATH"] || File.expand_path("~/.berkshelf")
    end

    # @return [String]
    def tmp_dir
      File.join(berkshelf_path, "tmp")
    end

    # Creates a temporary directory within the Berkshelf path
    #
    # @return [String]
    #   path to the created temporary directory
    def mktmpdir
      FileUtils.mkdir_p(tmp_dir)
      Dir.mktmpdir(nil, tmp_dir)
    end

    def cookbooks_dir
      File.join(berkshelf_path, "cookbooks")
    end

    # @return [Berkshelf::CookbookStore]
    def cookbook_store
      @cookbook_store ||= CookbookStore.new(cookbooks_dir)
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
      @formatter ||= Formatters::HumanReadable.new
    end

    # Specify the format for output
    #
    # @param [#to_sym] format_id
    #   the ID of the registered formatter to use
    #
    # @example Berkshelf.set_format :json
    #
    # @return [~Formatter]
    def set_format(format_id)
      @formatter = Formatters[format_id].new
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
