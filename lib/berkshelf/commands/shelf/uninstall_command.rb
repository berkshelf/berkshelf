module Berkshelf
  class Commands::Shelf::UninstallCommand < Commands::ShelfCommand
    option ['-f', '--force'], :flag, 'force removal, even if other cookbooks are contingent', default: false

    parameter 'NAME', 'cookbook to uninstall'
    parameter '[VERSION]', 'version to remove (default: all versions)'

    def execute
      find(name, version).each do |cookbook|
        uninstall_cookbook(cookbook, force?)
      end
    end
  end
end
