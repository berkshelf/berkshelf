module Berkshelf
  module Vagrant
    # @author Jamie Winsor <jamie@vialstudios.com>
    # @author Andrew Garson <andrew.garson@gmail.com>
    class Middleware
      def initialize(app, env)
        @app = app
        ::Berkshelf.config_path = "~/.chef/riot.rb"
        @berksfile = Berksfile.from_file("Berksfile")
        @vberks_path = File.join(File.expand_path("~/.berkshelf/vagrant"), env[:global_config].vm.host_name)
      end

      def call(env)
        if Berkshelf::Vagrant.chef_solo?(env)
          configure_cookbooks_path(env)

          env[:ui].info("[Berkshelf] installing cookbooks")
          install(env)

          env[:ui].info("[Berkshelf] copying cookbooks to Vagrant's berkshelf")
          copy(env)
        end

        @app.call(env)
      end

      private

        attr_reader :berksfile
        attr_reader :vberks_path

        def install(env)
          berksfile.install
        end

        def copy(env)
          FileUtils.mkdir_p(vberks_path)
          berksfile.cached_cookbooks.each do |cb|
            FileUtils.cp_r(cb.path, File.join(vberks_path, cb.cookbook_name))
          end
        end

        def configure_cookbooks_path(env)
          Berkshelf::Vagrant.provisioners(:chef_solo, env).each do |provisioner|
            provisioner.config.cookbooks_path.unshift(vberks_path)
          end
        end
    end
  end
end
