module Berkshelf
  class ContingentCommand < CLI
    include BerksfileOptions

    parameter 'NAME', 'name of dependent cookbook'

    def execute
      dependencies = Berkshelf.ui.mute { berksfile.install }.sort
      dependencies = dependencies.select { |cookbook| cookbook.dependencies.include?(name) }

      if dependencies.empty?
        Berkshelf.formatter.msg "There are no cookbooks contingent upon '#{name}' defined in this Berksfile"
      else
        Berkshelf.formatter.msg "Cookbooks in this Berksfile contingent upon #{name}:"
        print_list(dependencies)
      end
    end
  end
end
