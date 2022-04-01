require "mixlib/config" unless defined?(Mixlib::Config)
require "openssl" unless defined?(OpenSSL)

# we need this method, but have to inject it into mixlib-config directly
# to have it available from config contexts
module Mixlib
  module Config
    def each(&block)
      save(true).each(&block)
    end
  end
end

module Berkshelf
  class Config
    class << self
      # @return [String]
      def store_location
        File.join(Berkshelf.berkshelf_path, "config.json")
      end

      # @return [String]
      def local_location
        ENV["BERKSHELF_CONFIG"] || File.join(".", ".berkshelf", "config.json")
      end

      # @return [String]
      def path
        path = File.exist?(local_location) ? local_location : store_location
        File.expand_path(path)
      end

      # @param [Berkshelf::Config] config
      def set_config(config)
        @instance = config
      end

      # @param [String] new_path
      def set_path(new_path)
        @instance = nil
      end

      # Instantiate and return or just return the currently instantiated Berkshelf
      # configuration
      #
      # @return [Config]
      def instance
        @instance ||= new(path)
        coerce_ssl
      end

      # Reload the currently instantiated Berkshelf configuration
      #
      # @return [Config]
      def reload
        @instance = nil
        instance
      end

      # force proper X509 types from any configuration strings
      #
      # @return [Config]
      def coerce_ssl
        ssl = @instance[:ssl]
        ssl[:ca_cert] = OpenSSL::X509::Certificate.new(File.read(ssl[:ca_cert])) if ssl[:ca_cert] && ssl[:ca_cert].is_a?(String)
        ssl[:client_cert] = OpenSSL::X509::Certificate.new(File.read(ssl[:client_cert])) if ssl[:client_cert] && ssl[:client_cert].is_a?(String)
        ssl[:client_key] = OpenSSL::PKey::RSA.new(File.read(ssl[:client_key])) if ssl[:client_key] && ssl[:client_key].is_a?(String)
        @instance
      end

      def from_file(path)
        new(path)
      end
    end

    attr_accessor :path

    # @param [String] path
    def initialize(path = self.class.path)
      # this is a bit tricky, mixlib-config wants to extend a class and create effectively a global config object while
      # what we want to do is use an instance, so we create an anonymous class and shove it into an instance variable.
      # this is actually similar to what mixlib-config itself does to create config contexts.
      @klass = Class.new
      @klass.extend(Mixlib::Config)
      @klass.extend(BerksConfig)

      @path = File.expand_path(path)
      @klass.from_file(@path) if File.exist?(@path)
      # yeah, if !File.exist?() you just get back an empty config object

      Berkshelf.ui.warn "The `cookbook.copyright' config is deprecated and will be removed in a future release." unless cookbook.copyright.nil?
      Berkshelf.ui.warn "The `cookbook.email' config is deprecated and will be removed in a future release." unless cookbook.email.nil?
      Berkshelf.ui.warn "The `cookbook.license' config is deprecated and will be removed in a future release." unless cookbook.license.nil?
      Berkshelf.ui.warn "The `vagrant.vm.box' config is deprecated and will be removed in a future release." unless vagrant.vm.box.nil?
      Berkshelf.ui.warn "The `vagrant.vm.forward_port' config is deprecated and will be removed in a future release." unless vagrant.vm.forward_port.nil?
      Berkshelf.ui.warn "The `vagrant.vm.provision' config is deprecated and will be removed in a future release." unless vagrant.vm.provision.nil?
      Berkshelf.ui.warn "The `vagrant.vm.omnibus.version' config is deprecated and will be removed in a future release." unless vagrant.vm.omnibus.version.nil?
    end

    def method_missing(method, *args, &block)
      @klass.send(method, *args, &block)
    end

    module BerksConfig
      def self.extended(base)
        base.class_exec do
          config_strict_mode true
          config_context :api do
            default :timeout, "30"
          end
          config_context :chef do
            default :chef_server_url, Berkshelf.chef_config.chef_server_url
            default :validation_client_name, Berkshelf.chef_config.validation_client_name
            default :validation_key_path, Berkshelf.chef_config.validation_key
            default :client_key, Berkshelf.chef_config.client_key
            default :node_name, Berkshelf.chef_config.node_name
            default :trusted_certs_dir, Berkshelf.chef_config.trusted_certs_dir
            default :artifactory_api_key, Berkshelf.chef_config.artifactory_api_key
          end
          config_context :cookbook do
            default :copyright, nil
            default :email, nil
            default :license, nil
          end
          default :allowed_licenses, []
          default :raise_license_exception, false
          config_context :vagrant do
            config_context :vm do
              default :box, nil
              default :forward_port, nil
              default :provision, nil
              config_context :omnibus do
                default :version, nil
              end
            end
          end
          config_context :ssl do
            default :verify, true
            default :cert_store, false
            default :ca_file, nil
            default :ca_path, nil
            default :ca_cert, nil
            default :client_cert, nil
            default :client_key, nil
          end
          default :github, []
          default :gitlab, []
          # :git, :ssh, or :https
          default :github_protocol, :https
          config_context :git do
            default :default_branch, 'master' # for backwards compatibility
          end
        end
      end
    end
  end
end
