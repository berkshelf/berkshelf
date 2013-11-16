module Berkshelf
  class Commands::ApplyCommand < CLI
    include BerksfileOptions
    include SSLOptions

    parameter 'ENVIRONMENT', 'chef environment to apply changes to'

    def execute
      berksfile.apply(environment, options)
    end
  end
end
