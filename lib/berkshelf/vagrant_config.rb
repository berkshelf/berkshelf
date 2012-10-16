module Berkshelf
  class VagrantConfig
    DEFAULT_PATH = "~/.berkshelf/config.json"

    include Chozo::Config::JSON

    attribute :vagrant_vm_network_hostonly
    attribute :vagrant_vm_network_bridged
    attribute :vagrant_vm_forward_port

    def self.file
      File.expand_path DEFAULT_PATH
    end

    def self.instance
      @instance ||= begin
        VagrantConfig.from_file file
      rescue Chozo::Errors::ConfigNotFound
        VagrantConfig.new
      end
    end

    def initialize(*args)
      super

      @vagrant_vm_forward_port ||= {}
    end
  end
end
