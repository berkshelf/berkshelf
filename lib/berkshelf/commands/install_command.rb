module Berkshelf
  class InstallCommand < CLI
    include BerksfileOptions
    include FilterOptions

    def execute
      berksfile.install(options)
    end
  end
end
