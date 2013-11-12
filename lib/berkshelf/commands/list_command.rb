module Berkshelf
  class ListCommand < CLI
    include BerksfileOptions

    def execute
      dependencies = Berkshelf.ui.mute { berksfile.install }.sort

      if dependencies.empty?
        Berkshelf.formatter.msg 'There are no cookbooks installed by your Berksfile'
      else
        Berkshelf.formatter.msg 'Cookbooks installed by your Berksfile:'
        print_list(dependencies)
      end
    end
  end
end
