require "openssl" unless defined?(OpenSSL)

module Berkshelf
  class SSLPolicy

    # @return [Store]
    #   Holds trusted CA certificates used to verify peer certificates
    attr_reader :store

    def initialize
      @store = OpenSSL::X509::Store.new.tap(&:set_default_paths)

      set_custom_certs if ::File.exist?(trusted_certs_dir)
    end

    def add_trusted_cert(cert)
      @store.add_cert(cert)
    rescue OpenSSL::X509::StoreError => e
      raise e unless e.message.match(/cert already in hash table/)
    end

    def trusted_certs_dir
      config_dir = Berkshelf.config.chef.trusted_certs_dir.to_s.tr("\\", "/")
      if config_dir.empty? || !::File.exist?(config_dir)
        File.join(ENV["HOME"], ".chef", "trusted_certs")
      else
        config_dir
      end
    end

    def set_custom_certs
      ::Dir.glob("#{trusted_certs_dir}/{*.crt,*.pem}").each do |cert|
        cert = OpenSSL::X509::Certificate.new(IO.read(cert))
        add_trusted_cert(cert)
      end
    end
  end
end
