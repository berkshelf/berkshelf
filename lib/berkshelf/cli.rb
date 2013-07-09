require 'berkshelf'
require_relative 'config'
require_relative 'init_generator'
require_relative 'cookbook_generator'
require_relative 'commands/shelf'
require_relative 'commands/test_command'

module Berkshelf
  class Cli < Thor
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
        begin
          $stdin  = @stdin
          $stdout = @stdout
          $stderr = @stderr

          Berkshelf::Cli.start(@argv)
          @kernel.exit(0)
        rescue Berkshelf::BerkshelfError => e
          Berkshelf.ui.error e
          Berkshelf.ui.error "\t" + e.backtrace.join("\n\t") if ENV['BERKSHELF_DEBUG']
          @kernel.exit(e.status_code)
        rescue Ridley::Errors::RidleyError => e
          Berkshelf.ui.error "#{e.class} #{e}"
          Berkshelf.ui.error "\t" + e.backtrace.join("\n\t") if ENV['BERKSHELF_DEBUG']
          @kernel.exit(47)
        end
      end
    end

    class << self
      def dispatch(meth, given_args, given_opts, config)
        unless (given_args & ['-h', '--help']).empty?
          if given_args.length == 1
            # berks --help
            super
          else
            command = given_args.first
            super(meth, ['help', command].compact, nil, config)
          end
        else
          super
          Berkshelf.formatter.cleanup_hook unless config[:current_command].name == 'help'
        end
      end
    end

    def initialize(*args)
      super(*args)

      if @options[:config]
        unless File.exist?(@options[:config])
          raise ConfigNotFound.new(:berkshelf, @options[:config])
        end

        Berkshelf.config = Berkshelf::Config.from_file(@options[:config])
      end

      if @options[:debug]
        Berkshelf.logger.level = ::Logger::DEBUG
      end

      if @options[:quiet]
        Berkshelf.ui.mute!
      end

      Berkshelf.set_format @options[:format]
      @options = options.dup # unfreeze frozen options Hash from Thor
    end

    namespace 'berkshelf'

    map 'in'   => :install
    map 'up'   => :upload
    map 'ud'   => :update
    map 'ls'   => :list
    map 'book' => :cookbook
    map ['ver', '-v', '--version'] => :version

    default_task :install

    class_option :config,
      type: :string,
      desc: 'Path to Berkshelf configuration to use.',
      aliases: '-c',
      banner: 'PATH'
    class_option :format,
      type: :string,
      default: 'human',
      desc: 'Output format to use.',
      aliases: '-F',
      banner: 'FORMAT'
    class_option :quiet,
      type: :boolean,
      desc: 'Silence all informational output.',
      aliases: '-q',
      default: false
    class_option :debug,
      type: :boolean,
      desc: 'Output debug information',
      aliases: '-d',
      default: false

    method_option :force,
      type: :boolean,
      default: false,
      desc: 'create a new configuration file even if one already exists.'
    method_option :path,
      type: :string,
      default: Berkshelf.config.path,
      desc: 'The path to save the configuration file'
    desc 'configure', 'Create a new Berkshelf configuration file'
    def configure
      path = File.expand_path(options[:path])

      if File.exist?(path) && !options[:force]
        raise Berkshelf::ConfigExists, 'A configuration file already exists. Re-run with the --force flag if you wish to overwrite it.'
      end

      config = Berkshelf::Config.new(path)

      [
        'chef.chef_server_url',
        'chef.node_name',
        'chef.client_key',
        'chef.validation_client_name',
        'chef.validation_key_path',
        'vagrant.vm.box',
        'vagrant.vm.box_url',
      ].each do |attribute|
        default = config.get_attribute(attribute)

        message = "Enter value for #{attribute}"
        message << " (default: '#{default}')" if default
        message << ": "

        input = Berkshelf.ui.ask(message)

        if input.present?
          config.set_attribute(attribute, input)
        end
      end

      unless config.valid?
        raise InvalidConfiguration.new(config.errors)
      end

      config.save
      Berkshelf.config = config

      Berkshelf.formatter.msg "Config written to: '#{path}'"
    end

    method_option :except,
      type: :array,
      desc: 'Exclude cookbooks that are in these groups.',
      aliases: '-e'
    method_option :only,
      type: :array,
      desc: 'Only cookbooks that are in these groups.',
      aliases: '-o'
    method_option :berksfile,
      type: :string,
      default: Berkshelf::DEFAULT_FILENAME,
      desc: 'Path to a Berksfile to operate off of.',
      aliases: '-b',
      banner: 'PATH'
    method_option :path,
      type: :string,
      desc: 'Path to install cookbooks to (i.e. vendor/cookbooks).',
      aliases: '-p',
      banner: 'PATH'
    desc 'install', 'Install the cookbooks specified in the Berksfile'
    def install
      berksfile = ::Berkshelf::Berksfile.from_file(options[:berksfile])
      berksfile.install(options)
    end

    method_option :berksfile,
      type: :string,
      default: Berkshelf::DEFAULT_FILENAME,
      desc: 'Path to a Berksfile to operate off of.',
      aliases: '-b',
      banner: 'PATH'
    method_option :except,
      type: :array,
      desc: 'Exclude cookbooks that are in these groups.',
      aliases: '-e'
    method_option :only,
      type: :array,
      desc: 'Only cookbooks that are in these groups.',
      aliases: '-o'
    desc 'update [COOKBOOKS]', 'Update the cookbooks (and dependencies) specified in the Berksfile'
    def update(*cookbook_names)
      berksfile = Berksfile.from_file(options[:berksfile])

      update_options = {
        cookbooks: cookbook_names
      }.merge(options).symbolize_keys

      berksfile.update(update_options)
    end

    method_option :berksfile,
      type: :string,
      default: Berkshelf::DEFAULT_FILENAME,
      desc: 'Path to a Berksfile to operate off of.',
      aliases: '-b',
      banner: 'PATH'
    method_option :except,
      type: :array,
      desc: 'Exclude cookbooks that are in these groups.',
      aliases: '-e'
    method_option :only,
      type: :array,
      desc: 'Only cookbooks that are in these groups.',
      aliases: '-o'
    method_option :no_freeze,
      type: :boolean,
      default: false,
      desc: 'Do not freeze uploaded cookbook(s).'
    method_option :force,
      type: :boolean,
      default: false,
      desc: 'Upload all cookbook(s) even if a frozen one exists on the Chef Server.'
    method_option :ssl_verify,
      type: :boolean,
      default: nil,
      desc: 'Disable/Enable SSL verification when uploading cookbooks.'
    method_option :skip_syntax_check,
      type: :boolean,
      default: false,
      desc: 'Skip Ruby syntax check when uploading cookbooks.',
      aliases: '-s'
    method_option :halt_on_frozen,
      type: :boolean,
      default: false,
      desc: 'Halt uploading and exit if the Chef Server has a frozen version of the cookbook(s).'
    desc 'upload [COOKBOOKS]', 'Upload the cookbook specified in the Berksfile to the Chef Server'
    def upload(*cookbook_names)
      berksfile = ::Berkshelf::Berksfile.from_file(options[:berksfile])

      upload_options             = Hash[options.except(:no_freeze, :berksfile)].symbolize_keys
      upload_options[:cookbooks] = cookbook_names
      upload_options[:freeze]    = false if options[:no_freeze]

      berksfile.upload(upload_options)
    end

    method_option :berksfile,
      type: :string,
      default: Berkshelf::DEFAULT_FILENAME,
      desc: 'Path to a Berksfile to operate off of.',
      aliases: '-b',
      banner: 'PATH'
    method_option :ssl_verify,
      type: :boolean,
      default: nil,
      desc: 'Disable/Enable SSL verification when locking cookbooks.'
    desc 'apply ENVIRONMENT', 'Apply the cookbook version locks from Berksfile.lock to a Chef environment'
    def apply(environment_name)
      berksfile    = ::Berkshelf::Berksfile.from_file(options[:berksfile])
      lock_options = Hash[options].symbolize_keys

      berksfile.apply(environment_name, lock_options)
    end

    method_option :berksfile,
      type: :string,
      default: Berkshelf::DEFAULT_FILENAME,
      desc: 'Path to a Berksfile to operate off of.',
      aliases: '-b',
      banner: 'PATH'
    method_option :except,
      type: :array,
      desc: 'Exclude cookbooks that are in these groups.',
      aliases: '-e'
    method_option :only,
      type: :array,
      desc: 'Only cookbooks that are in these groups.',
      aliases: '-o'
    desc 'outdated [COOKBOOKS]', 'List dependencies that have new versions available that satisfy their constraints'
    def outdated(*cookbook_names)
      berksfile = Berkshelf::Berksfile.from_file(options[:berksfile])
      Berkshelf.formatter.msg 'Listing outdated cookbooks with newer versions available...'

      outdated_options = { cookbooks: cookbook_names }.merge(options).symbolize_keys
      berksfile.outdated(outdated_options)
    end

    desc 'init [PATH]', 'Initialize Berkshelf in the given directory'
    def init(path = '.')
      Berkshelf.formatter.deprecation '--git is now the default' if options[:git]
      Berkshelf.formatter.deprecation '--vagrant is now the default' if options[:vagrant]

      if File.chef_cookbook?(path)
        options[:chefignore]     = true
        options[:metadata_entry] = true
      end

      ::Berkshelf::InitGenerator.new([path], options).invoke_all

      ::Berkshelf.formatter.msg 'Successfully initialized'
    end

    method_option :berksfile,
      type: :string,
      default: Berkshelf::DEFAULT_FILENAME,
      desc: 'Path to a Berksfile to operate off of.',
      aliases: '-b',
      banner: 'PATH'
    desc 'list', 'List all cookbooks and their dependencies specified by your Berksfile'
    def list
      berksfile    = Berksfile.from_file(options[:berksfile])
      dependencies = Berkshelf.ui.mute { berksfile.install }.sort

      if dependencies.empty?
        Berkshelf.formatter.msg 'There are no cookbooks installed by your Berksfile'
      else
        Berkshelf.formatter.msg 'Cookbooks installed by your Berksfile:'
        print_list(dependencies)
      end
    end

    method_option :berksfile,
      type: :string,
      default: Berkshelf::DEFAULT_FILENAME,
      desc: "Path to a Berksfile to operate off of.",
      aliases: "-b",
      banner: "PATH"
    desc "show [COOKBOOK]", "Display name, author, copyright, and dependency information about a cookbook"
    def show(name)
      berksfile = Berksfile.from_file(options[:berksfile])
      cookbook  = berksfile.install(cookbooks: name).first

      unless cookbook
        raise CookbookNotFound, "Cookbook '#{name}' is not installed by your Berksfile"
      end

      Berkshelf.formatter.show(cookbook)
    end

    method_option :berksfile,
      type: :string,
      default: Berkshelf::DEFAULT_FILENAME,
      desc: 'Path to a Berksfile to operate off of.',
      aliases: '-b',
      banner: 'PATH'
    desc 'contingent COOKBOOK', 'List all cookbooks that depend on the given cookbook'
    def contingent(name)
      berksfile    = Berksfile.from_file(options[:berksfile])
      dependencies = Berkshelf.ui.mute { berksfile.install }.sort
      dependencies = dependencies.select { |cookbook| cookbook.dependencies.include?(name) }

      if dependencies.empty?
        Berkshelf.formatter.msg "There are no cookbooks contingent upon '#{name}' defined in this Berksfile"
      else
        Berkshelf.formatter.msg "Cookbooks in this Berksfile contingent upon #{name}:"
        print_list(dependencies)
      end
    end

    method_option :berksfile,
      type: :string,
      default: Berkshelf::DEFAULT_FILENAME,
      desc: 'Path to a Berksfile to operate off of.',
      aliases: '-b',
      banner: 'PATH'
    method_option :output,
      type: :string,
      default: '.',
      desc: 'Path to output the tarball',
      aliases: '-o',
      banner: 'PATH'
    method_option :ignore_chefignore,
      type: :boolean,
      desc: 'Do not apply the chefignore to the packaged contents',
      default: false
    desc "package [COOKBOOK]", "Package a cookbook and it's dependencies as a tarball"
    def package(name = nil)
      berksfile = Berkshelf::Berksfile.from_file(options[:berksfile])
      berksfile.package(name, options)
    end

    desc 'version', 'Display version and copyright information'
    def version
      Berkshelf.formatter.msg version_header
      Berkshelf.formatter.msg "\n"
      Berkshelf.formatter.msg license
    end

    desc 'cookbook NAME', 'Create a skeleton for a new cookbook'
    def cookbook(name)
      Berkshelf.formatter.deprecation '--git is now the default' if options[:git]
      Berkshelf.formatter.deprecation '--vagrant is now the default' if options[:vagrant]

      ::Berkshelf::CookbookGenerator.new([File.join(Dir.pwd, name), name], options).invoke_all
    end
    tasks['cookbook'].options = Berkshelf::CookbookGenerator.class_options

    private

      def version_header
        "Berkshelf (#{Berkshelf::VERSION})"
      end

      def license
        File.read(Berkshelf.root.join('LICENSE'))
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
