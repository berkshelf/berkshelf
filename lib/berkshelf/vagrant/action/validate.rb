module Berkshelf
  module Vagrant
    module Action
      # @author Jamie Winsor <reset@riotgames.com>
      #
      # As of Vagrant 1.0.5 it is not possible to validate configuration values of
      # a configuraiton that was not explicitly described in a Vagrant::Config.run block.
      #
      # In our case we want some values set for our middleware stacks even if the user does
      # not explicitly set values for settings in `config.berkshelf`.
      class Validate
        def initialize(app, env)
          @app = app
        end

        def call(env)
          recorder = ::Vagrant::Config::ErrorRecorder.new
          env[:vm].config.berkshelf.validate(env[:vm].env, recorder)

          unless recorder.errors.empty?
            raise ::Vagrant::Errors::ConfigValidationFailed,
              messages: ::Vagrant::Util::TemplateRenderer.render("config/validation_failed", errors: { berkshelf: recorder })
          end

          @app.call(env)
        end
      end
    end
  end
end
