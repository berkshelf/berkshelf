module Berkshelf
  class Config
    DEFAULT_PATH = "~/.berkshelf/config.json"

    include Chozo::Config::JSON

    attribute :vagrant_vm_network_hostonly
    attribute :vagrant_vm_network_bridged
    attribute :vagrant_vm_forward_port, default: Hash.new

    class << self
      def file
        File.expand_path DEFAULT_PATH
      end

      def instance
        @instance ||= begin
          from_file file
        rescue Chozo::Errors::ConfigNotFound
          new
        end
      end
    end
  end
end
