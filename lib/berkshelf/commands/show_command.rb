module Berkshelf
  class Commands::ShowCommand < CLI
    include BerksfileOptions

    parameter 'NAME', 'cookbook to show'

    def execute
      Berkshelf.formatter.show(berksfile.retrieve_locked(name))
    end
  end
end
