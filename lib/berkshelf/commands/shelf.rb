module Berkshelf
  # All tasks that operate on the Berkshelf shelf.
  class Shelf < Thor
    desc 'list', 'List all cookbooks and their versions'
    def list
      cookbooks = store.cookbooks.inject({}) do |hash, cookbook|
        (hash[cookbook.cookbook_name] ||= []).push(cookbook.version)
        hash
      end

      if cookbooks.empty?
        Berkshelf.formatter.msg 'There are no cookbooks in the Berkshelf shelf'
      else
        Berkshelf.formatter.msg 'Cookbooks in the Berkshelf shelf:'
        cookbooks.sort.each do |cookbook, versions|
          Berkshelf.formatter.msg("  * #{cookbook} (#{versions.sort.join(', ')})")
        end
      end
    end

    method_option :version, aliases: '-v', type: :string, desc: 'Version to show'
    desc 'show', 'Display information about a cookbook in the Berkshelf shelf'
    def show(name)
      cookbooks = find(name, options[:version])

      if options[:version]
        Berkshelf.formatter.msg "Displaying '#{name}' (#{options[:version]}) in the Berkshelf shelf:"
      else
        Berkshelf.formatter.msg "Displaying all versions of '#{name}' in the Berkshelf shelf:"
      end

      cookbooks.each do |cookbook|
        Berkshelf.formatter.show(cookbook)
        Berkshelf.formatter.msg("\n")
      end
    end

    method_option :version, aliases: '-v', type: :string,  desc: 'Version to remove'
    method_option :force,   aliases: '-f', type: :boolean, desc: 'Force removal, even if other cookbooks are contingent', default: false
    desc 'uninstall', 'Remove a cookbook from the Berkshelf shelf'
    def uninstall(name)
      cookbooks = find(name, options[:version])
      cookbooks.each { |c| uninstall_cookbook(c, options[:force]) }
    end

    no_tasks do
      # Shortcut helper to the CookbookStore
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
        unless options[:force] || (contingent = contingencies(cookbook)).empty?
          contingent = contingent.map { |c| "#{c.cookbook_name} (#{c.version})" }.join(', ')
          confirm = Berkshelf.ui.ask("[#{contingent}] depend on #{cookbook.cookbook_name}.\n\nAre you sure you want to continue? (y/N)")

          exit unless confirm.upcase[0] == 'Y'
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

  class Cli < Thor
    desc 'shelf SUBCOMMAND', 'Interact with the cookbook store'
    subcommand 'shelf', Berkshelf::Shelf
  end
end
