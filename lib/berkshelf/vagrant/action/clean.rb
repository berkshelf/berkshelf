module Berkshelf
  module Vagrant
    module Action
      # @author Jamie Winsor <jamie@vialstudios.com>
      class Clean
        attr_reader :shelf

        def initialize(app, env)
          @app = app
          @shelf = Berkshelf::Vagrant.shelf_for(env)
        end

        def call(env)
          if Berkshelf::Vagrant.chef_solo?(env[:global_config])
            Berkshelf::Vagrant.info("cleaning Vagrant's shelf", env)
            FileUtils.remove_dir(self.shelf, fore: true)
          end

          @app.call(env)
        end
      end
    end
  end
end
