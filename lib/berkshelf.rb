require 'buff/extensions'
require 'archive/tar/minitar'
require 'erb'
require 'forwardable'
require 'json'
require 'pathname'
require 'ridley'
require 'solve'
require 'tmpdir'
require 'uri'
require 'zlib'

require_relative 'berkshelf/errors'
require_relative 'berkshelf/core_ext'
require_relative 'berkshelf/mixin'
require_relative 'berkshelf/version'

module Berkshelf
  autoload :APIClient,      'berkshelf/api_client'
  autoload :Berksfile,      'berkshelf/berksfile'
  autoload :CachedCookbook, 'berkshelf/cached_cookbook'
  autoload :CLI,            'berkshelf/cli'
  autoload :CommunityREST,  'berkshelf/community_rest'
  autoload :Config,         'berkshelf/config'
  autoload :CookbookStore,  'berkshelf/cookbook_store'
  autoload :Dependency,     'berkshelf/dependency'
  autoload :Downloader,     'berkshelf/downloader'
  autoload :Formatter,      'berkshelf/formatter'
  autoload :Git,            'berkshelf/git'
  autoload :Installer,      'berkshelf/installer'
  autoload :Location,       'berkshelf/location'
  autoload :Lockfile,       'berkshelf/lockfile'
  autoload :Logger,         'berkshelf/logger'
  autoload :Mercurial,      'berkshelf/mercurial'
  autoload :Mixin,          'berkshelf/mixin'
  autoload :Resolver,       'berkshelf/resolver'
  autoload :Source,         'berkshelf/source'
  autoload :SourceURI,      'berkshelf/source_uri'
  autoload :UI,             'berkshelf/ui'

  module Commands
    autoload :ApplyCommand,      'berkshelf/commands/apply_command'
    autoload :ContingentCommand, 'berkshelf/commands/contingent_command'
    autoload :CookbookCommand,   'berkshelf/commands/cookbook_command'
    autoload :InitCommand,       'berkshelf/commands/init_command'
    autoload :InstallCommand,    'berkshelf/commands/install_command'
    autoload :ListCommand,       'berkshelf/commands/list_command'
    autoload :OutdatedCommand,   'berkshelf/commands/outdated_command'
    autoload :PackageCommand,    'berkshelf/commands/package_command'
    autoload :ShelfCommand,      'berkshelf/commands/shelf_command'
    autoload :ShowCommand,       'berkshelf/commands/show_command'
    autoload :UpdateCommand,     'berkshelf/commands/update_command'
    autoload :UploadCommand,     'berkshelf/commands/upload_command'
    autoload :VendorCommand,     'berkshelf/commands/vendor_command'

    module Shelf
      autoload :ListCommand,      'berkshelf/commands/shelf/list_command'
      autoload :ShowCommand,      'berkshelf/commands/shelf/show_command'
      autoload :UninstallCommand, 'berkshelf/commands/shelf/uninstall_command'
    end
  end

  puts
  puts
  puts Berkshelf::Commands::ShowCommand
  puts
  puts

  module Formatters
    autoload :HumanFormatter, 'berkshelf/formatters/human_formatter'
    autoload :JSONFormatter,  'berkshelf/formatters/json_formatter'
    autoload :NullFormatter,  'berkshelf/formatters/null_formatter'
  end

  module Locations
    autoload :GitLocation,       'berkshelf/locations/git_location'
    autoload :GitHubLocation,    'berkshelf/locations/github_location'
    autoload :MercurialLocation, 'berkshelf/locations/mercurial_location'
    autoload :PathLocation,      'berkshelf/locations/path_location'
  end

  DEFAULT_FILENAME = 'Berksfile'.freeze

  class << self
    include Berkshelf::Mixin::Logging

    attr_writer :berkshelf_path
    attr_accessor :ui
    attr_accessor :logger

    # Unset all instance variables (which are actually cached on the parent
    # class) to prevent caching. This is mostly used in the tests, but it can
    # be useful when using Berkshelf as a library.
    def reset!
      instance_variables.each(&method(:remove_instance_variable))
    end

    # @return [Pathname]
    def root
      @root ||= Pathname.new(File.expand_path('../', File.dirname(__FILE__)))
    end

    # @return [Berkshelf::UI, Berkshelf::SilentUI]
    #   A basic shell on Windows, colored everywhere else
    def ui
      @ui ||= Berkshelf::UI.new
    end

    # Returns the filepath to the location Berkshelf will use for
    # storage; temp files will go here, Cookbooks will be downloaded
    # to or uploaded from here. By default this is '~/.berkshelf' but
    # can be overridden by specifying a value for the ENV variable
    # 'BERKSHELF_PATH'.
    #
    # @return [String]
    def berkshelf_path
      @berkshelf_path || ENV['BERKSHELF_PATH'] || File.expand_path('~/.berkshelf')
    end

    # The Berkshelf configuration.
    #
    # @return [Berkshelf::Config]
    def config
      Berkshelf::Config.instance
    end

    # @param [Berkshelf::Config] config
    def config=(config)
      Berkshelf::Config.set_config(config)
    end

    # The Chef configuration file.
    #
    # @return [Ridley::Chef::Config]
    def chef_config
      @chef_config ||= Ridley::Chef::Config.new(ENV['BERKSHELF_CHEF_CONFIG'])
    end

    # @param [Ridley::Chef::Config] config
    def chef_config=(config)
      @chef_config = config
    end

    # Initialize the filepath for the Berkshelf path..
    def initialize_filesystem
      FileUtils.mkdir_p(berkshelf_path, mode: 0755)

      unless File.writable?(berkshelf_path)
        raise InsufficientPrivledges, "You do not have permission to write to '#{berkshelf_path}'!" +
          " Please either chown the directory or use a different filepath."
      end
    end

    # @return [String]
    def tmp_dir
      File.join(berkshelf_path, 'tmp')
    end

    # Creates a temporary directory within the Berkshelf path
    #
    # @return [String]
    #   path to the created temporary directory
    def mktmpdir
      FileUtils.mkdir_p(tmp_dir)
      Dir.mktmpdir(nil, tmp_dir)
    end

    # @return [Berkshelf::CookbookStore]
    def cookbook_store
      CookbookStore.instance
    end

    # Get the appropriate Formatter object based on the formatter
    # classes that have been registered.
    #
    # @return [~Formatter]
    def formatter
      @formatter ||= Formatters::HumanFormatter.new
    end

    # Specify the format for output
    #
    # @param [Symbol] format
    #   the ID of the registered formatter to use
    #
    # @example Berkshelf.set_format(:json)
    #
    # @return [~Formatter]
    def set_format(format)
      @formatter = Formatter.find(format).new
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

Ridley.logger = Berkshelf.logger = Logger.new(STDOUT)
Berkshelf.logger.level = Logger::WARN
