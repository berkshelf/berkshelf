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
      Berkshelf.config_path = @options[:config]
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
      default: Berkshelf::DEFAULT_CONFIG,
      desc: "Path to Knife or Chef configuration to use.",
      aliases: "-c",
      banner: "PATH"
    class_option :format,
      type: :string,
      default: "human",
      desc: "Output format to use.",
      aliases: "-F",
      banner: "FORMAT"

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
    desc "install", "Install the Cookbooks specified by a Berksfile or a Berksfile.lock."
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
    desc "update", "Update all Cookbooks and their dependencies specified by a Berksfile to their latest versions."
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
    desc "upload", "Upload the Cookbooks specified by a Berksfile or a Berksfile.lock to a Chef Server."
    def upload
      Berkshelf.load_config 
      berksfile = ::Berkshelf::Berksfile.from_file(options[:berksfile])

      berksfile.upload(
        server_url: Chef::Config[:chef_server_url],
        client_name: Chef::Config[:node_name],
        client_key: Chef::Config[:client_key],
        ssl: {
          verify: options[:ssl_verify]
        }
      )
    end

    desc "init [PATH]", "Prepare a local path to have its Cookbook dependencies managed by Berkshelf."
    def init(path = Dir.pwd)
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

    method_option :vagrant,
      type: :boolean,
      desc: "Creates a Vagrantfile and dynamically change other generated files to support Vagrant"
    method_option :git,
      type: :boolean,
      desc: "Creates additional git specific files if your project will be managed by git"
    method_option :foodcritic,
      type: :boolean,
      desc: "Creates a Thorfile with Foodcritic support to lint test your cookbook"
    method_option :scmversion,
      type: :boolean,
      desc: "Creates a Thorfile with SCMVersion support to manage versions for continuous integration"
    method_option :no_bundler,
      type: :boolean,
      desc: "Skips generation of a Gemfile and other Bundler specific support"
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
    method_option :vagrant_vm_box,
      type: :string,
      default: "Berkshelf-CentOS-6.3-x86_64-minimal",
      desc: "Name of the Vagrant box to use"
    method_option :vagrant_vm_box_url,
      type: :string,
      default: "https://dl.dropbox.com/u/31081437/Berkshelf-CentOS-6.3-x86_64-minimal.box",
      desc: "Url to retrieve the Vagrant box if it does not already exist"
    method_option :vagrant_vm_host_name,
      type: :string,
      desc: "Host name for the Vagrant box"

    desc "cookbook NAME", "Create a skeleton for a new cookbook"
    def cookbook(name)
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
