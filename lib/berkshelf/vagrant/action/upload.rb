module Berkshelf
  module Vagrant
    module Action
      # @author Jamie Winsor <jamie@vialstudios.com>
      class Upload
        attr_reader :berksfile
        attr_reader :node_name
        attr_reader :client_key

        def initialize(app, env)
          @app = app
          @node_name  = env[:global_config].berkshelf.node_name
          @client_key = env[:global_config].berkshelf.client_key
          @berksfile  = Berksfile.from_file(env[:global_config].berkshelf.berksfile_path)
        end

        def call(env)
          if Berkshelf::Vagrant.chef_client?(env[:global_config])
            upload(env)
          end

          @app.call(env)
        end

        private

          def upload(env)
            Berkshelf::Vagrant.provisioners(:chef_client, env[:global_config]).each do |provisioner|
              Berkshelf.formatter.msg "uploading cookbooks to '#{provisioner.config.chef_server_url}'"
              berksfile.upload(
                provisioner.config.chef_server_url,
                node_name: self.node_name,
                client_key: self.client_key
              )
            end
          end
      end
    end
  end
end
