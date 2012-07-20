require 'thor'
require 'berkshelf'

module Berkshelf
  # @author Jamie Winsor <jamie@vialstudios.com>
  class Cli < Thor
    def initialize(*)
      super
      # JW TODO: Replace Chef::Knife::UI with our own UI class
      ::Berkshelf.ui = Chef::Knife::UI.new(STDOUT, STDERR, STDIN, {})
      ::Berkshelf.config_path = @options[:config]
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

    method_option :shims,
      type: :string,
      default: nil,
      lazy_default: File.join(Dir.pwd, "cookbooks"),
      desc: "Create a directory of shims pointing to Cookbook Versions.",
      banner: "PATH"
    method_option :without,
      type: :array,
      default: Array.new,
      desc: "Exclude cookbooks that are in these groups.",
      aliases: "-w"
    method_option :berksfile,
      type: :string,
      default: File.join(Dir.pwd, Berkshelf::DEFAULT_FILENAME),
      desc: "Path to a Berksfile to operate off of.",
      aliases: "-b",
      banner: "PATH"
    desc "install", "Install the Cookbooks specified by a Berksfile or a Berskfile.lock."
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
    method_option :without,
      type: :array,
      default: Array.new,
      desc: "Exclude cookbooks that are in these groups.",
      aliases: "-w"
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
    method_option :without,
      type: :array,
      default: Array.new,
      desc: "Exclude cookbooks that are in these groups.",
      aliases: "-w"
    method_option :freeze,
      type: :boolean,
      default: false,
      desc: "Freeze the uploaded cookbooks so that they cannot be overwritten"
    option :force,
      type: :boolean,
      default: false,
      desc: "Upload all cookbooks even if a frozen one exists on the target Chef Server"
    desc "upload", "Upload the Cookbooks specified by a Berksfile or a Berksfile.lock to a Chef Server."
    def upload
      Berkshelf.load_config 
      berksfile = ::Berkshelf::Berksfile.from_file(options[:berksfile])
      berksfile.upload(Chef::Config[:chef_server_url], options)
    end

    desc "init [PATH]", "Prepare a local path to have its Cookbook dependencies managed by Berkshelf."
    def init(path = Dir.pwd)
      if File.chef_cookbook?(path)
        options[:chefignore] = true
        options[:metadata_entry] = true
      end

      ::Berkshelf::InitGenerator.new([path], options).invoke_all

      ::Berkshelf.ui.info "Successfully initialized"
    end

    desc "version", "Display version and copyright information"
    def version
      Berkshelf.ui.info version_header
      Berkshelf.ui.info "\n"
      Berkshelf.ui.info license
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
