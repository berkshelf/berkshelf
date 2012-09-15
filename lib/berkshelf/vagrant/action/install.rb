module Berkshelf
  module Vagrant
    module Action
      # @author Jamie Winsor <jamie@vialstudios.com>
      # @author Andrew Garson <andrew.garson@gmail.com>
      class Install
        attr_reader :config
        attr_reader :shelf
        attr_reader :berksfile

        def initialize(app, env)
          @app                  = app
          @shelf                = Berkshelf::Vagrant.shelf_for(env)
          @config               = env[:global_config].berkshelf
          @berksfile            = Berksfile.from_file(@config.berksfile_path)

          Berkshelf.config_path = @config.config_path
        end

        def call(env)
          if Berkshelf::Vagrant.chef_solo?(env[:global_config])
            configure_cookbooks_path(env)
            install(env)
          end

          @app.call(env)
        end

        private

          def install(env)
            Berkshelf::Vagrant.info("installing cookbooks", env)
            opts = {
              path: self.shelf
            }.merge(self.config.to_hash).symbolize_keys!
            berksfile.install(opts)
          end

          def configure_cookbooks_path(env)
            Berkshelf::Vagrant.provisioners(:chef_solo, env[:global_config]).each do |provisioner|
              provisioner.config.cookbooks_path.unshift(self.shelf)
            end
          end
      end
    end
  end
end
