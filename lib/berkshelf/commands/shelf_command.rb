module Berkshelf
  module Shelf
    autoload :ListCommand,      'berkshelf/commands/shelf/list_command'
    autoload :ShowCommand,      'berkshelf/commands/shelf/show_command'
    autoload :UninstallCommand, 'berkshelf/commands/shelf/uninstall_command'
  end

  class ShelfCommand < CLI
    # Set the default command to `show`
    default_subcommand = 'show'

    subcommand 'list',      'list all cookbooks and versions', Berkshelf::Shelf::ListCommand
    subcommand 'show',      'show descriptive information about a cookbook', Berkshelf::Shelf::ShowCommand
    subcommand 'uninstall', 'show descriptive information about a cookbook', Berkshelf::Shelf::UninstallCommand

    # Shortcut method to the cookbook store.
    #
    # @return [Berkshelf::CookbookStore]
    def store
      Berkshelf.cookbook_store
    end

    # Find a cookbook in the store by name and version. If the no version
    # is given, all cookbooks with the given name are returned. Otherwise,
    # only the cookbook matching the given version is returned.
    #
    # @param [String] name
    #   the name of the cookbook to find
    # @param [String, nil] version
    #   the version of the cookbook to find
    #
    # @raise [Berkshelf::CookbookNotFound]
    #   if the cookbook does not exist
    #
    # @return [Array<Berkshelf::CachedCookbook>]
    #   the list of cookbooks that match the parameters - this is always an
    #   array!
    def find(name, version = nil)
      cookbooks = if version
        [store.cookbook(name, version)].compact
      else
        store.cookbooks(name).sort
      end

      if cookbooks.empty?
        if version
          raise Berkshelf::CookbookNotFound, "Cookbook '#{name}' (#{version}) is not in the Berkshelf shelf"
        else
          raise Berkshelf::CookbookNotFound, "Cookbook '#{name}' is not in the Berkshelf shelf"
        end
      end

      cookbooks
    end

    # Uninstall a cookbook from the CookbookStore. This method assumes the
    # cookbook exists, so perform that validation elsewhere.
    #
    # By default, this method will request confirmation from the user to
    # delete a cookbook that is a dependency on another (contingent). This
    # behavior can be overridden by setting the second parameter `force` to
    # true.
    #
    # @param [Berkshelf::CachedCookbook] cookbook
    #   the cookbook to uninstall
    # @param [Boolean] force
    #   if false, the user will need to confirm before uninstalling
    #   if contingencies exist
    def uninstall_cookbook(cookbook, force = false)
      unless force || (contingent = contingencies(cookbook)).empty?
        contingent = contingent.map { |c| "#{c.cookbook_name} (#{c.version})" }.join(', ')
        confirm = Berkshelf.ui.ask("[#{contingent}] depend on #{cookbook.cookbook_name}.\n\nAre you sure you want to continue? (y/N)")

        exit unless confirm.to_s.upcase[0] == 'Y'
      end

      FileUtils.rm_rf(cookbook.path)
      Berkshelf.formatter.msg("Successfully uninstalled #{cookbook.cookbook_name} (#{cookbook.version})")
    end

    # Return a list of all cookbooks which are contingent upon the given
    # cookbook.
    #
    # @param [Berkshelf::CachedCookbook] cookbook
    #   the cached cookbook to search for dependencies against
    #
    # @return [Array<Berkshelf::CachedCookbook>]
    #   the list of cookbooks which depend on the parameter
    def contingencies(cookbook)
      store.cookbooks.select { |c| c.dependencies.include?(cookbook.cookbook_name) }
    end
  end
end
