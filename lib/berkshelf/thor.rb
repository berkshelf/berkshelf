require 'berkshelf'

module Berkshelf
  class ThorTasks < Thor
    namespace "berkshelf"

    method_option :config,
      type: :string,
      aliases: "-c",
      desc: "Knife configuration file to use.",
      required: true
    method_option :without,
      type: :array, 
      aliases: "-w", 
      desc: "Exclude cookbooks that are in these groups",
      default: Array.new
    method_option :force,
      type: :array,
      desc: "Fail the build if any of the specified tags are matched.",
      default: false
    method_option :freeze,
      type: :array,
      desc: "Freeze the uploaded cookbooks so that they cannot be overwritten.",
      default: false
    desc "upload", "shit"
    def upload
      ::Berkshelf.ui = Chef::Knife::UI.new(STDOUT, STDERR, STDIN, {})
      Chef::Config.from_file(File.expand_path(options[:config]))
      cookbook_file = ::Berkshelf::Berksfile.from_file(File.join(Dir.pwd, "Berksfile"))
      cookbook_file.upload(Chef::Config[:chef_server_url],
        without: options[:without],
        freeze: options[:freeze],
        force: options[:force]
      )
    end
  end
end
