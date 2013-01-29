module Berkshelf
  module Vagrant
    module Action
      # @author Jamie Winsor <jamie@vialstudios.com>
      class SetUI
        def initialize(app, env)
          @app = app
        end

        def call(env)
          Berkshelf.ui = ::Vagrant::UI::Colored.tap { |c| c.send(:include, ::Berkshelf::UI).new("Berkshelf")
          @app.call(env)
        end
      end
    end
  end
end
