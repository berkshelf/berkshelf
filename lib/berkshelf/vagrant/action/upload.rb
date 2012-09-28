module Berkshelf
  module Vagrant
    module Action
      # @author Jamie Winsor <jamie@vialstudios.com>
      class Upload
        attr_reader :berksfile
        attr_reader :node_name
        attr_reader :client_key
        attr_reader :ssl_verify

        def initialize(app, env)
          @app = app
          @node_name  = env[:vm].config.berkshelf.node_name
          @client_key = env[:vm].config.berkshelf.client_key
          @ssl_verify = env[:vm].config.berkshelf.ssl_verify
          @berksfile  = Berksfile.from_file(env[:vm].config.berkshelf.berksfile_path)
        end

        def call(env)
          if Berkshelf::Vagrant.chef_client?(env[:vm].config)
            upload(env)
          end

          @app.call(env)
        end

        private

          def upload(env)
            Berkshelf::Vagrant.provisioners(:chef_client, env[:vm].config).each do |provisioner|
              Berkshelf.formatter.msg "uploading cookbooks to '#{provisioner.config.chef_server_url}'"
              berksfile.upload(
                server_url: provisioner.config.chef_server_url,
                client_name: self.node_name,
                client_key: self.client_key,
                ssl: {
                  verify: self.ssl_verify
                }
              )
            end
          end
      end
    end
  end
end
