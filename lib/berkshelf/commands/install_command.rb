module Berkshelf
  class Commands::InstallCommand < CLI
    include BerksfileOptions
    include FilterOptions

    def execute
      berksfile.install(options)
    end
  end
end
