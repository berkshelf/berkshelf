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
          @config               = env[:vm].config.berkshelf
          Berkshelf.config_path = @config.config_path
          Berkshelf.load_config
          @berksfile            = Berksfile.from_file(@config.berksfile_path)
        end

        def call(env)
          if Berkshelf::Vagrant.chef_solo?(env[:vm].config)
            configure_cookbooks_path(env)
            install(env)
          end

          @app.call(env)
        end

        private

          def install(env)
            Berkshelf.formatter.msg "installing cookbooks..."
            opts = {
              path: self.shelf
            }.merge(self.config.to_hash).symbolize_keys!
            berksfile.install(opts)
          end

          def configure_cookbooks_path(env)
            Berkshelf::Vagrant.provisioners(:chef_solo, env[:vm].config).each do |provisioner|
              provisioner.config.cookbooks_path.unshift(self.shelf)
            end
          end
      end
    end
  end
end
