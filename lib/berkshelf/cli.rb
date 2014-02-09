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
        if given_args.length > 1 && !(given_args & Thor::HELP_MAPPINGS).empty?
          command = given_args.first

          if self.subcommands.include?(command)
            super(meth, [command, 'help'].compact, nil, config)
          else
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
        ENV["BERKSHELF_DEBUG"] = "true"
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
      aliases: '-p',
      hide: true
    desc 'install', 'Install the cookbooks specified in the Berksfile'
    def install
      if options[:path]
        # TODO: Remove in Berkshelf 4.0
        Berkshelf.formatter.deprecation "`berks install --path [PATH}` has been replaced by `berks vendor`."
        Berkshelf.formatter.deprecation "Re-run your command as `berks vendor [PATH]` or see `berks help vendor`."
        exit(1)
      end

      berksfile = Berksfile.from_options(options)
      berksfile.install
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
      berksfile = Berksfile.from_options(options)
      berksfile.update(*cookbook_names)
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
      berksfile = Berkshelf::Berksfile.from_file(options[:berksfile])

      options[:cookbooks] = cookbook_names
      options[:freeze]    = !options[:no_freeze]
      options[:validate]  = false if options[:skip_syntax_check]

      berksfile.upload(options.symbolize_keys)
    end

    method_option :lockfile,
      type: :string,
      default: Berkshelf::Lockfile::DEFAULT_FILENAME,
      desc: 'Path to a Berksfile.lock to operate off of.',
      aliases: '-b',
      banner: 'PATH'
    method_option :ssl_verify,
      type: :boolean,
      default: nil,
      desc: 'Disable/Enable SSL verification when locking cookbooks.'
    desc 'apply ENVIRONMENT', 'Apply version locks from Berksfile.lock to a Chef environment'
    def apply(environment_name)
      unless File.exist?(options[:lockfile])
        raise LockfileNotFound, "No lockfile found at #{options[:lockfile]}"
      end

      lockfile     = Berkshelf::Lockfile.from_file(options[:lockfile])
      lock_options = Hash[options].symbolize_keys

      lockfile.apply(environment_name, lock_options)
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
      berksfile = Berksfile.from_options(options)
      options[:cookbooks] = cookbook_names
      outdated = berksfile.outdated(options.symbolize_keys)

      if outdated.empty?
        Berkshelf.formatter.msg "All cookbooks up to date!"
      else
        Berkshelf.formatter.msg "The following cookbooks have newer versions:"
      end

      Berkshelf.formatter.outdated(outdated)
    end

    desc 'init [PATH]', 'Initialize Berkshelf in the given directory'
    def init(path = '.')
      Berkshelf.formatter.deprecation '--git is now the default' if options[:git]
      Berkshelf.formatter.deprecation '--vagrant is now the default' if options[:vagrant]

      Berkshelf::InitGenerator.new([path], options).invoke_all

      Berkshelf.formatter.msg 'Successfully initialized'
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
    desc 'list', 'List cookbooks and their dependencies specified by your Berksfile'
    def list
      berksfile = Berksfile.from_options(options)
      Berkshelf.formatter.list(berksfile.list)
    end

    method_option :berksfile,
      type: :string,
      default: Berkshelf::DEFAULT_FILENAME,
      desc: "Path to a Berksfile to operate off of.",
      aliases: "-b",
      banner: "PATH"
    desc "show [COOKBOOK]", "Display name, author, copyright, and dependency information about a cookbook"
    def show(name)
      berksfile = Berksfile.from_options(options)
      cookbook  = berksfile.retrieve_locked(name)
      Berkshelf.formatter.show(cookbook)
    end

    method_option :berksfile,
      type: :string,
      default: Berkshelf::DEFAULT_FILENAME,
      desc: 'Path to a Berksfile to operate off of.',
      aliases: '-b',
      banner: 'PATH'
    desc 'contingent COOKBOOK', 'List all cookbooks that depend on the given cookbook in your Berksfile'
    def contingent(name)
      berksfile    = Berksfile.from_options(options)
      dependencies = berksfile.cookbooks.select do |cookbook|
        cookbook.dependencies.include?(name)
      end

      if dependencies.empty?
        Berkshelf.formatter.msg "There are no cookbooks in this Berksfile contingent upon '#{name}'."
      else
        Berkshelf.formatter.msg "Cookbooks in this Berksfile contingent upon '#{name}':"
        print_list(dependencies)
      end
    end

    method_option :berksfile,
      type: :string,
      default: Berkshelf::DEFAULT_FILENAME,
      desc: 'Path to a Berksfile to operate off of.',
      aliases: '-b',
      banner: 'PATH'
    method_option :except,
      type: :array,
      desc: "Exclude cookbooks that are in these groups.",
      aliases: "-e"
    method_option :only,
      type: :array,
      desc: "Only cookbooks that are in these groups.",
      aliases: "-o"
    desc "package [PATH]", "Vendor and archive the dependencies of a Berksfile"
    def package(path = nil)
      if path.nil?
        path ||= File.join(Dir.pwd, "cookbooks-#{Time.now.to_i}.tar.gz")
      else
        path = File.expand_path(path)
      end

      berksfile = Berksfile.from_options(options)
      berksfile.package(path)
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
    desc "vendor [PATH]", "Vendor the cookbooks specified by the Berksfile into a directory"
    def vendor(path = File.join(Dir.pwd, "berks-cookbooks"))
      berksfile = Berkshelf::Berksfile.from_options(options)
      berksfile.vendor(path)
    end

    desc 'version', 'Display version and copyright information'
    def version
      Berkshelf.formatter.version
    end

    desc 'cookbook NAME', 'Create a skeleton for a new cookbook'
    def cookbook(name)
      Berkshelf.formatter.deprecation '--git is now the default' if options[:git]
      Berkshelf.formatter.deprecation '--vagrant is now the default' if options[:vagrant]

      Berkshelf::CookbookGenerator.new([File.join(Dir.pwd, name), name], options).invoke_all
    end
    tasks['cookbook'].options = Berkshelf::CookbookGenerator.class_options

    private
      # Print a list of the given cookbooks. This is used by various
      # methods like {list} and {contingent}.
      #
      # @param [Array<CachedCookbook>] cookbooks
      #
      def print_list(cookbooks)
        Array(cookbooks).sort.each do |cookbook|
          Berkshelf.formatter.msg "  * #{cookbook.cookbook_name} (#{cookbook.version})"
        end
      end
  end
end
