require 'openssl'
require 'pathname'

module Berkshelf
  class SSLPolicy
    attr_reader :store

    def initialize
      @store = OpenSSL::X509::Store.new.tap do |store|
        store.set_default_paths
      end

      self.set_custom_certs
    end

    def trusted_certs_dir
      "#{ENV['HOME']}/.chef/trusted_certs"
    end

    def set_custom_certs
      certs = Pathname.new(trusted_certs_dir).children
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
