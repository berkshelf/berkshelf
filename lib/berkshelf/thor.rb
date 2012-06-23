require 'berkshelf'

module Berkshelf
  class ThorTasks < Thor
    namespace "berkshelf"

    method_option :config,
      type: :string,
      aliases: "-c",
      desc: "Knife configuration file to use.",
      default: File.expand_path("~/.chef/knife.rb")
    method_option :without,
      type: :array, 
      aliases: "-w", 
      desc: "Exclude cookbooks that are in these groups",
      default: Array.new
    method_option :force,
      type: :boolean,
      desc: "Fail the build if any of the specified tags are matched.",
      default: false
    method_option :freeze,
      type: :boolean,
      desc: "Freeze the uploaded cookbooks so that they cannot be overwritten.",
      default: false
    desc "upload", "Upload the sources defined in your Berksfile and their dependencies to a Chef Server."
    def upload
      begin
        Chef::Config.from_file(File.expand_path(options[:config]))
      rescue Errno::ENOENT
        say "Unable to find a Knife config at #{options[:config]}. Specify a different path with --config.", :red
        exit(10)
      end

      ::Berkshelf.ui = Chef::Knife::UI.new(STDOUT, STDERR, STDIN, {})
      cookbook_file = ::Berkshelf::Berksfile.from_file(File.join(Dir.pwd, "Berksfile"))
      cookbook_file.upload(Chef::Config[:chef_server_url],
        without: options[:without],
        freeze: options[:freeze],
        force: options[:force]
      )
    end
  end
end
