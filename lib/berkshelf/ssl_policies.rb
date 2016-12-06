require 'openssl'
require 'pathname'

module Berkshelf
  class SSLPolicy
    attr_reader :store

    def initialize
      set_store
    end

    def set_store
      if ::File.exist?(trusted_certs_dir)
        @store = OpenSSL::X509::Store.new.tap do |store|
          store.set_default_paths
        end

        self.set_custom_certs
      else
        @store = nil
      end
    end

    def trusted_certs_dir
      config_dir = Berkshelf.config.chef.trusted_certs_dir.to_s
      if config_dir.empty? && !::File.exist?(config_dir)
        trusted_certs_dir = "#{ENV['HOME']}/.chef/trusted_certs"
      else
        trusted_certs_dir = config_dir
      end

      trusted_certs_dir
    end

    def set_custom_certs
      certs = Pathname.glob("#{trusted_certs_dir}/" "{*.crt,*.pem}")
      certs.each do |cert|
        cert = OpenSSL::X509::Certificate.new(IO.read(cert))
        add_trusted_cert(cert)
      end
    end

    def add_trusted_cert(cert)
      @store.add_cert(cert)
    rescue OpenSSL::X509::StoreError => e
      raise e unless e.message == 'cert already in hash table'
    end
  end
end
