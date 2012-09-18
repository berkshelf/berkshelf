module Berkshelf
  module Vagrant
    module Action
      # @author Jamie Winsor <jamie@vialstudios.com>
      class SetFormatter
        attr_reader :shelf

        def initialize(app, env)
          @app = app
        end

        def call(env)
          Berkshelf.set_format "vagrant"
          @app.call(env)
        end
      end
    end
  end
end
