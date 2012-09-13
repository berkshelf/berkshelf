module Berkshelf
  module Vagrant
    # @author Jamie Winsor <jamie@vialstudios.com>
    # @author Andrew Garson <andrew.garson@gmail.com>
    class Middleware
      attr_reader :shelf
      attr_reader :berksfile

      def initialize(app, env)
        @app = app
        Berkshelf.config_path = env[:global_config].berkshelf.config_path
        @berksfile            = Berksfile.from_file(env[:global_config].berkshelf.berksfile_path)
        @shelf                = Berkshelf::Vagrant.shelf_for(env)
      end

      def call(env)
        if Berkshelf::Vagrant.chef_solo?(env)
          configure_cookbooks_path(env)
          install(env)
        end

        @app.call(env)
      end

      private

        def install(env)
          Berkshelf::Vagrant.info("installing cookbooks", env)
          berksfile.install(path: self.shelf)
        end

        def configure_cookbooks_path(env)
          Berkshelf::Vagrant.provisioners(:chef_solo, env).each do |provisioner|
            provisioner.config.cookbooks_path.unshift(self.shelf)
          end
        end
    end
  end
end
