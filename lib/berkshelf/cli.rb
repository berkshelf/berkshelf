require 'berkshelf'
require 'clamp'

module Berkshelf
  #
  # Main CLI application entry point
  #
  class CLI < Clamp::Command
    module BerksfileOptions
      def self.included(base)
        base.class_eval do
          option ['-b', '--berksfile'], 'PATH', 'path to the Berksfile', default: 'Berksfile', attribute_name: 'berksfile_path'
        end
      end

      def berksfile
        @berksfile ||= Berksfile.from_file(berksfile_path)
      end
    end

    module FilterOptions
      def self.included(base)
        base.instance_eval do
          option ['-e', '--except'], 'LIST', 'groups to exclude', multivalued: true
          option ['-o', '--only'],   'LIST', 'groups to exclusively include', multivalued: true
        end
      end

      def options
        super.merge(
          only:   only_list,
          except: except_list,
        )
      end
    end

    module SSLOptions
      def self.included(base)
        base.class_eval do
          option ['-s', '--[no-]ssl-verify'], :flag, 'use Ruby\'s SSL verification', default: true
        end
      end

      def options
        super.merge(ssl_verify: ssl_verify?)
      end
    end

    # This is the main entry point for the CLI. It exposes the method {#execute!} to
    # start the CLI.
    #
    # @note the arity of {#initialize} and {#execute!} are extremely important for testing purposes. It
    #   is a requirement to perform in-process testing with Aruba. In process testing is much faster
    #   than spawning a new Ruby process for each test.
    class Runner
      def initialize(argv, stdin = STDIN, stdout = STDOUT, stderr = STDERR, kernel = Kernel)
        @argv, @stdin, @stdout, @stderr, @kernel = argv, stdin, stdout, stderr, kernel
      end

      def execute!
        $stdin  = @stdin
        $stdout = @stdout
        $stderr = @stderr

        Berkshelf::CLI.run('berks', @argv)
        Berkshelf.formatter.cleanup_hook
        @kernel.exit(0)
      rescue Berkshelf::BerkshelfError => e
        Berkshelf.ui.alert_error e
        Berkshelf.ui.alert_error "\t" + e.backtrace.join("\n\t") if ENV['BERKSHELF_DEBUG']
        @kernel.exit(e.status_code)
      rescue Ridley::Errors::RidleyError => e
        Berkshelf.ui.alert_error "#{e.class} #{e}"
        Berkshelf.ui.alert_error "\t" + e.backtrace.join("\n\t") if ENV['BERKSHELF_DEBUG']
        @kernel.exit(47)
      ensure
        $stdin  = STDIN
        $stdout = STDOUT
        $stderr = STDERR
      end
    end

    # Global options
    option ['-c', '--config'], 'PATH', 'path to Berkshelf configuration file' do |path|
      raise ConfigNotFound.new(:berkshelf, path) unless File.exist?(path)
      Berkshelf.config = Config.from_file(path)
    end
    option ['-F', '--format'], 'FORMAT', 'output format to use', default: 'human' do |format|
      Berkshelf.set_format(format.to_sym)
    end
    option ['-q', '--quiet'],  :flag, 'silence informational output' do
      Berkshelf.ui.mute!
    end
    option ['-d', '--debug'],  :flag, 'output debug information' do
      Berkshelf.logger.level = ::Logger::DEBUG
    end

    # Listen for -v, --version and output the version header
    option ['-v', '--version'], :flag, 'Show version' do
      Berkshelf.formatter.version
      exit(0)
    end

    # Set the default command to `install`
    default_subcommand = 'install'

    # Subcommands
    subcommand 'apply',       'apply cookbook version locks to a Chef environment', Commands::ApplyCommand
    subcommand 'contingent',  'list cookbooks that depend on the given cookbook', Commands::ContingentCommand
    subcommand 'cookbook',    'create a skeleton for a new cookbook', Commands::CookbookCommand
    subcommand 'init',        'initialize Berkshelf in the given directory', Commands::InitCommand
    subcommand 'install',     'install the cookbooks in the Berksfile', Commands::InstallCommand
    subcommand 'list',        'list all cookbooks and dependencies from your Berksfile', Commands::ListCommand
    subcommand 'outdated',    'list remote cookbooks that have newer versions', Commands::OutdatedCommand
    subcommand 'package',     'package a cookbook and dependencies as a tarball', Commands::PackageCommand
    subcommand 'shelf',       'interact with the cookbook store', Commands::ShelfCommand
    subcommand 'show',        'show descriptive information about a cookbook', Commands::ShowCommand
    subcommand 'update',      'update the given cookbooks list', Commands::UpdateCommand
    subcommand 'upload',      'upload the cookbooks to the Chef Server', Commands::UploadCommand
    subcommand 'vendor',      'vendor cookbooks into a directory', Commands::VendorCommand

    protected

      # The default list of options.
      #
      # @return [Hash]
      def options
        {}
      end

      # Print a list of the given cookbooks. This is used by various
      # methods like {list} and {contingent}.
      #
      # @param [Array<CachedCookbook>] cookbooks
      #
      def print_list(cookbooks)
        Array(cookbooks).each do |cookbook|
          Berkshelf.formatter.msg "  * #{cookbook.cookbook_name} (#{cookbook.version})"
        end
      end
  end
end
