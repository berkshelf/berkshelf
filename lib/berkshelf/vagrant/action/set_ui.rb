module Berkshelf
  module Vagrant
    module Action
      # @author Jamie Winsor <reset@riotgames.com>
      class SetUI
        def initialize(app, env)
          @app = app
        end

        def call(env)
          Berkshelf.ui = ::Vagrant::UI::Colored.new('Berkshelf')
          @app.call(env)
        end
      end
    end
  end
end
