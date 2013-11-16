module Berkshelf
  class Commands::UpdateCommand < CLI
    include BerksfileOptions
    include FilterOptions

    parameter '[COOKBOOKS] ...', 'cookbooks to update'

    def execute
      berksfile.update(options)
    end

    def options
      super.merge(cookbooks: cookbooks_list)
    end
  end
end
