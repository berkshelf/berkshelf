module Berkshelf
  class Commands::OutdatedCommand < CLI
    include BerksfileOptions
    include FilterOptions

    parameter '[COOKBOOKS] ...', 'cookbooks to seek a new version'

    def execute
      outdated = berksfile.outdated(options)

      if outdated.empty?
        Berkshelf.formatter.msg "All cookbooks up to date!"
      else
        Berkshelf.formatter.msg "The following cookbooks have newer versions:"
      end

      Berkshelf.formatter.outdated(outdated)
    end

    def options
      super.merge(cookbooks: cookbooks_list)
    end
  end
end
