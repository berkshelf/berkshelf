# XXX: work around logger spam from hashie
# https://github.com/intridea/hashie/issues/394
begin
  require "hashie"
  require "hashie/logger"
  Hashie.logger = Logger.new(nil)
rescue LoadError
  # intentionally left blank
end

require "buff/extensions"
require "cleanroom"
require "digest/md5"
require "forwardable"
require "json"
require "pathname"
require "ridley"
require "semverse"
require "solve"
require "thor"
require "uri"
require "celluloid"

JSON.create_id = nil

require_relative "berkshelf/core_ext"
require_relative "berkshelf/thor_ext"

module Berkshelf
  Encoding.default_external = Encoding::UTF_8

  def self.fix_proxies
    ENV["http_proxy"] = ENV["HTTP_PROXY"] if ENV["HTTP_PROXY"] && !ENV["http_proxy"]
    ENV["https_proxy"] = ENV["HTTPS_PROXY"] if ENV["HTTPS_PROXY"] && !ENV["https_proxy"]
    ENV["ftp_proxy"] = ENV["FTP_PROXY"] if ENV["FTP_PROXY"] && !ENV["ftp_proxy"]
    ENV["no_proxy"] = ENV["NO_PROXY"] if ENV["NO_PROXY"] && !ENV["no_proxy"]
  end

  fix_proxies

  require_relative "berkshelf/version"
  require_relative "berkshelf/errors"

  module Mixin
    autoload :Git,     "berkshelf/mixin/git"
    autoload :Logging, "berkshelf/mixin/logging"
  end

  autoload :FileSyncer, "berkshelf/file_syncer"
  autoload :Shell,      "berkshelf/shell"
  autoload :Uploader,   "berkshelf/uploader"
  autoload :Visualizer, "berkshelf/visualizer"

  autoload :BaseFormatter,  "berkshelf/formatters/base"
  autoload :HumanFormatter, "berkshelf/formatters/human"
  autoload :JsonFormatter,  "berkshelf/formatters/json"
  autoload :NullFormatter,  "berkshelf/formatters/null"

  autoload :Location,       "berkshelf/location"
  autoload :BaseLocation,   "berkshelf/locations/base"
  autoload :GitLocation,    "berkshelf/locations/git"
  autoload :GithubLocation, "berkshelf/locations/github"
  autoload :PathLocation,   "berkshelf/locations/path"

  DEFAULT_FILENAME = "Berksfile".freeze

  class << self
    include Mixin::Logging

    attr_writer :berkshelf_path
    attr_accessor :ui

    # @return [Pathname]
    def root
      @root ||= Pathname.new(File.expand_path("../", File.dirname(__FILE__)))
    end

    # @return [Berkshelf::Shell]
    def ui
      @ui ||= Berkshelf::Shell.new
    end

    # Returns the filepath to the location Berkshelf will use for
    # storage; temp files will go here, Cookbooks will be downloaded
    # to or uploaded from here. By default this is '~/.berkshelf' but
    # can be overridden by specifying a value for the ENV variable
    # 'BERKSHELF_PATH'.
    #
    # @return [String]
    def berkshelf_path
      @berkshelf_path ||= File.expand_path(ENV["BERKSHELF_PATH"] || "~/.berkshelf")
    end

    # The Berkshelf configuration.
    #
    # @return [Berkshelf::Config]
    def config
      Berkshelf::Config.instance
    end

    # @param [Berkshelf::Config]
    def config=(config)
      Berkshelf::Config.set_config(config)
    end

    # The Chef configuration file.
    #
    # @return [Ridley::Chef::Config]
    def chef_config
      @chef_config ||= Ridley::Chef::Config.new(ENV["BERKSHELF_CHEF_CONFIG"])
    end

    # @param [Ridley::Chef::Config]
    def chef_config=(config)
      @chef_config = config
    end

    # Initialize the filepath for the Berkshelf path..
    def initialize_filesystem
      FileUtils.mkdir_p(berkshelf_path, mode: 0755)

      unless File.writable?(berkshelf_path)
        raise InsufficientPrivledges.new(berkshelf_path)
      end
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
      @formatter ||= HumanFormatter.new
    end

    def ssl_policy
      @ssl_policy ||= SSLPolicy.new
    end

    # @raise [Berkshelf::ChefConnectionError]
    def ridley_connection(options = {}, &block)
      ssl_options              = {}
      ssl_options[:verify]     = if options[:ssl_verify].nil?
                                   Berkshelf.config.ssl.verify
                                 else
                                   options[:ssl_verify]
                                 end
      ssl_options[:cert_store] = ssl_policy.store if ssl_policy.store

      ridley_options               = options.slice(:ssl)
      ridley_options[:server_url]  = options[:server_url] || Berkshelf.config.chef.chef_server_url
      ridley_options[:client_name] = options[:client_name] || Berkshelf.config.chef.node_name
      ridley_options[:client_key]  = options[:client_key] || Berkshelf.config.chef.client_key
      ridley_options[:ssl]         = ssl_options

      unless ridley_options[:server_url].present?
        raise ChefConnectionError, "Missing required attribute in your Berkshelf configuration: chef.server_url"
      end

      unless ridley_options[:client_name].present?
        raise ChefConnectionError, "Missing required attribute in your Berkshelf configuration: chef.node_name"
      end

      unless ridley_options[:client_key].present?
        raise ChefConnectionError, "Missing required attribute in your Berkshelf configuration: chef.client_key"
      end

      # @todo  Something scary going on here - getting an instance of Kitchen::Logger from test-kitchen
      # https://github.com/opscode/test-kitchen/blob/master/lib/kitchen.rb#L99
      Celluloid.logger = nil unless ENV["DEBUG_CELLULOID"]
      Ridley.open(ridley_options, &block)
    rescue Ridley::Errors::RidleyError => ex
      log.exception(ex)
      raise ChefConnectionError, ex # todo implement
    end

    # Specify the format for output
    #
    # @param [#to_sym] format_id
    #   the ID of the registered formatter to use
    #
    # @example Berkshelf.set_format :json
    #
    # @return [~Formatter]
    def set_format(name)
      id = name.to_s.capitalize
      @formatter = Berkshelf.const_get("#{id}Formatter").new
    end

    # Location an executable in the current user's $PATH
    #
    # @return [String, nil]
    #   the path to the executable, or +nil+ if not present
    def which(executable)
      if File.file?(executable) && File.executable?(executable)
        executable
      elsif ENV["PATH"]
        path = ENV["PATH"].split(File::PATH_SEPARATOR).find do |p|
          File.executable?(File.join(p, executable))
        end
        path && File.expand_path(executable, path)
      end
    end

    private

    def null_stream
      @null ||= begin
        strm = STDOUT.clone
        strm.reopen(RbConfig::CONFIG["host_os"] =~ /mswin|mingw/ ? "NUL:" : "/dev/null")
        strm.sync = true
        strm
      end
    end
  end
end

require_relative "berkshelf/lockfile"
require_relative "berkshelf/base_generator"
require_relative "berkshelf/berksfile"
require_relative "berkshelf/cached_cookbook"
require_relative "berkshelf/cli"
require_relative "berkshelf/community_rest"
require_relative "berkshelf/cookbook_generator"
require_relative "berkshelf/cookbook_store"
require_relative "berkshelf/config"
require_relative "berkshelf/dependency"
require_relative "berkshelf/downloader"
require_relative "berkshelf/init_generator"
require_relative "berkshelf/installer"
require_relative "berkshelf/logger"
require_relative "berkshelf/resolver"
require_relative "berkshelf/source"
require_relative "berkshelf/source_uri"
require_relative "berkshelf/validator"
require_relative "berkshelf/ssl_policies"

Ridley.logger          = Berkshelf.logger
Berkshelf.logger.level = Logger::WARN
Celluloid.logger.level = Logger::ERROR
