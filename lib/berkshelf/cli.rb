require 'berkshelf'

module Berkshelf
  Thor::Base.shell = Berkshelf::UI

  # @author Jamie Winsor <jamie@vialstudios.com>
  class Cli < Thor
    class << self
      def dispatch(meth, given_args, given_opts, config)
        super
        Berkshelf.formatter.cleanup_hook unless config[:current_task].name == "help"
      end
    end
    
    def initialize(*args)
      super(*args)

      if @options[:config]
        unless File.exist?(@options[:config])
          raise BerksConfigNotFound, "You specified a path to a configuration file that did not exist: '#{@options[:config]}'"
        end
        Berkshelf::Config.path = @options[:config]
      end

      Berkshelf.set_format @options[:format]
      @options = options.dup # unfreeze frozen options Hash from Thor
    end

    namespace "berkshelf"

    map 'in'        => :install
    map 'up'        => :upload
    map 'ud'        => :update
    map 'ver'       => :version
    map 'book'      => :cookbook

    class_option :config,
      type: :string,
      desc: "Path to Berkshelf configuration to use.",
      aliases: "-c",
      banner: "PATH"
    class_option :format,
      type: :string,
      default: "human",
      desc: "Output format to use.",
      aliases: "-F",
      banner: "FORMAT"

    method_option :force,
      type: :boolean,
      default: false,
      desc: "create a new configuration file even if one already exists."
    desc "configure", "Create a new configuration file to customize Berkshelf's behavior"
    def configure(path = Berkshelf::Config.path)
      path = File.expand_path(path)

      if File.exist?(path) && !options[:force]
        raise Berkshelf::ConfigExists, "A configuration file already exists. Re-run with the --force flag if you wish to overwrite it."
      end

      @config = Berkshelf::Config.new(path)

      [
        "chef.chef_server_url",
        "chef.node_name",
        "chef.client_key",
        "chef.validation_client_name",
        "chef.validation_key_path",
        "vagrant.vm.box",
        "vagrant.vm.box_url",
      ].each do |attribute|
        default = @config.get_attribute(attribute)

        message = "Enter value for #{attribute}"
        message << " (default: '#{default}')" if default
        message << ": "

        input = Berkshelf.ui.ask(message)

        if input.present?
          @config.set_attribute(attribute, input)
        end
      end

      unless @config.valid?
        raise InvalidConfiguration.new(@config.errors)
      end

      @config.save

      Berkshelf.formatter.msg "Config written to: '#{path}'"
    end

    method_option :except,
      type: :array,
      desc: "Exclude cookbooks that are in these groups.",
      aliases: "-e"
    method_option :only,
      type: :array,
      desc: "Only cookbooks that are in these groups.",
      aliases: "-o"
    method_option :berksfile,
      type: :string,
      default: File.join(Dir.pwd, Berkshelf::DEFAULT_FILENAME),
      desc: "Path to a Berksfile to operate off of.",
      aliases: "-b",
      banner: "PATH"
    method_option :path,
      type: :string,
      desc: "Path to install cookbooks to (i.e. vendor/cookbooks).",
      aliases: "-p",
      banner: "PATH"
    desc "install", "Install the Cookbooks specified by a Berksfile or a Berksfile.lock"
    def install
      berksfile = ::Berkshelf::Berksfile.from_file(options[:berksfile])
      berksfile.install(options)
    end

    method_option :berksfile,
      type: :string,
      default: File.join(Dir.pwd, Berkshelf::DEFAULT_FILENAME),
      desc: "Path to a Berksfile to operate off of.",
      aliases: "-b",
      banner: "PATH"
    method_option :except,
      type: :array,
      desc: "Exclude cookbooks that are in these groups.",
      aliases: "-e"
    method_option :only,
      type: :array,
      desc: "Only cookbooks that are in these groups.",
      aliases: "-o"
    desc "update", "Update all Cookbooks and their dependencies specified by a Berksfile to their latest versions"
    def update
      Lockfile.remove!
      invoke :install
    end

    method_option :berksfile,
      type: :string,
      default: File.join(Dir.pwd, Berkshelf::DEFAULT_FILENAME),
      desc: "Path to a Berksfile to operate off of.",
      aliases: "-b",
      banner: "PATH"
    method_option :except,
      type: :array,
      desc: "Exclude cookbooks that are in these groups.",
      aliases: "-e"
    method_option :only,
      type: :array,
      desc: "Only cookbooks that are in these groups.",
      aliases: "-o"
    method_option :freeze,
      type: :boolean,
      default: false,
      desc: "Freeze the uploaded cookbooks so that they cannot be overwritten"
    option :force,
      type: :boolean,
      default: false,
      desc: "Upload all cookbooks even if a frozen one exists on the target Chef Server"
    option :ssl_verify,
      type: :boolean,
      default: true,
      desc: "Disable/Enable SSL verification when uploading cookbooks"
    desc "upload", "Upload the Cookbooks specified by a Berksfile or a Berksfile.lock to a Chef Server"
    def upload
      berksfile = ::Berkshelf::Berksfile.from_file(options[:berksfile])

      unless Berkshelf::Config.instance.chef.chef_server_url.present?
        msg = "Could not upload cookbooks: Missing Chef server_url."
        msg << " Generate or update your Berkshelf configuration that contains a valid Chef Server URL."
        raise UploadFailure, msg
      end

      unless Berkshelf::Config.instance.chef.node_name.present?
        msg = "Could not upload cookbooks: Missing Chef node_name."
        msg << " Generate or update your Berkshelf configuration that contains a valid Chef node_name."
        raise UploadFailure, msg
      end

      berksfile.upload(
        server_url: Berkshelf::Config.instance.chef.chef_server_url,
        client_name: Berkshelf::Config.instance.chef.node_name,
        client_key: Berkshelf::Config.instance.chef.client_key,
        ssl: {
          verify: (options[:ssl_verify] || Berkshelf::Config.instance.ssl.verify)
        }
      )
    rescue Ridley::Errors::ClientKeyFileNotFound => e
      msg = "Could not upload cookbooks: Missing Chef client key: '#{Berkshelf::Config.instance.chef.client_key}'."
      msg << " Generate or update your Berkshelf configuration that contains a valid path to a Chef client key."
      raise UploadFailure, msg
    end

    method_option :foodcritic,
      type: :boolean,
      desc: "Creates a Thorfile with Foodcritic support to lint test your cookbook"
    method_option :scmversion,
      type: :boolean,
      desc: "Creates a Thorfile with SCMVersion support to manage versions for continuous integration"
    method_option :no_bundler,
      type: :boolean,
      desc: "Skips generation of a Gemfile and other Bundler specific support"
    method_option :vagrant,
      type: :boolean,
      hide: true
    method_option :skip_vagrant,
      type: :boolean,
      desc: "Skips adding a Vagrantfile and adding supporting gems to the Gemfile"
    method_option :git,
      type: :boolean,
      hide: true
    method_option :skip_git,
      type: :boolean,
      desc: "Skips adding a .gitignore and running git init in the cookbook directory"
    desc "init [PATH]", "Prepare a local path to have its Cookbook dependencies managed by Berkshelf"
    def init(path = Dir.pwd)
      Berkshelf.formatter.deprecation "--git is now the default" if options[:git]
      Berkshelf.formatter.deprecation "--vagrant is now the default" if options[:vagrant]

      if File.chef_cookbook?(path)
        options[:chefignore] = true
        options[:metadata_entry] = true
      end

      ::Berkshelf::InitGenerator.new([path], options).invoke_all

      ::Berkshelf.formatter.msg "Successfully initialized"
    end

    desc "version", "Display version and copyright information"
    def version
      Berkshelf.formatter.msg version_header
      Berkshelf.formatter.msg "\n"
      Berkshelf.formatter.msg license
    end

    method_option :foodcritic,
      type: :boolean,
      desc: "Creates a Thorfile with Foodcritic support to lint test your cookbook"
    method_option :scmversion,
      type: :boolean,
      desc: "Creates a Thorfile with SCMVersion support to manage versions for continuous integration"
    method_option :license,
      type: :string,
      default: "reserved",
      desc: "License for cookbook (apachev2, gplv2, gplv3, mit, reserved)",
      aliases: "-L"
    method_option :maintainer,
      type: :string,
      desc: "Name of cookbook maintainer",
      aliases: "-m"
    method_option :maintainer_email,
      type: :string,
      desc: "Email address of cookbook maintainer",
      aliases: "-e"
    method_option :no_bundler,
      type: :boolean,
      desc: "Skips generation of a Gemfile and other Bundler specific support"
    method_option :vagrant,
      type: :boolean,
      hide: true
    method_option :skip_vagrant,
      type: :boolean,
      desc: "Skips adding a Vagrantfile and adding supporting gems to the Gemfile"
    method_option :git,
      type: :boolean,
      hide: true
    method_option :skip_git,
      type: :boolean,
      desc: "Skips adding a .gitignore and running git init in the cookbook directory"
    desc "cookbook NAME", "Create a skeleton for a new cookbook"
    def cookbook(name)
      Berkshelf.formatter.deprecation "--git is now the default" if options[:git]
      Berkshelf.formatter.deprecation "--vagrant is now the default" if options[:vagrant]

      unless Config.instance.valid?
        raise InvalidConfiguration.new(Config.instance.errors)
      end

      ::Berkshelf::CookbookGenerator.new([name, File.join(Dir.pwd, name)], options).invoke_all
    end

    private

      def version_header
        "Berkshelf (#{Berkshelf::VERSION})"
      end

      def license
        File.read(Berkshelf.root.join('LICENSE'))
      end
  end
end
