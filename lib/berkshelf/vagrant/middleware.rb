module Berkshelf
  module Vagrant
    # @author Jamie Winsor <jamie@vialstudios.com>
    # @author Andrew Garson <andrew.garson@gmail.com>
    class Middleware
      attr_reader :shelf

      def initialize(app, env)
        @app = app
        ::Berkshelf.config_path = "~/.chef/riot.rb"
        @berksfile = Berksfile.from_file("Berksfile")
        @shelf = Berkshelf::Vagrant.shelf_for(env)
      end

      def call(env)
        if Berkshelf::Vagrant.chef_solo?(env)
          configure_cookbooks_path(env)
          install(env)
          clean_shelf!
          copy(env)
        end

        @app.call(env)
      end

      private

        attr_reader :berksfile

        def clean_shelf!
          FileUtils.rm_rf(shelf)
        end

        def install(env)
          Berkshelf::Vagrant.info("installing cookbooks", env)
          berksfile.install
        end

        def copy(env)
          Berkshelf::Vagrant.info("copying cookbooks to Vagrant's shelf", env)
          FileUtils.mkdir_p(self.shelf)
          berksfile.cached_cookbooks.each do |cb|
            FileUtils.cp_r(cb.path, File.join(self.shelf, cb.cookbook_name))
          end
        end

        def configure_cookbooks_path(env)
          Berkshelf::Vagrant.provisioners(:chef_solo, env).each do |provisioner|
            provisioner.config.cookbooks_path.unshift(self.shelf)
          end
        end
    end
  end
end
