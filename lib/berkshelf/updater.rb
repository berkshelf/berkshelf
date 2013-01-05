module Berkshelf
  # This class is responsible for installing cookbooks and handling the
  # `berks install` command.
  #
  # @author Seth Vargo <sethvargo@gmail.com>
  class Updater < Command
    # Update the sources listed in the Berksfile, or specific sources passed
    # to the updater.
    #
    # - If no sources are supplied, assume the user wants to update all
    #   cookbooks. Thus, just destroy the lockfile and delegate to the
    #   {Berkshelf::Installer.install}
    #
    # - If a list of sources are supplied, or a group is specified via
    #   <tt>:only</tt> or <tt>:except</tt>, the lockfile is loaded, the
    #   requested sources are unlocked, and the lockfile is saved. Then, the
    #   {Berkshelf::Installer.install} command is run, which will fetch the
    #   most recent sources that match the version constraint in the
    #   Berksfile (if one was specified).
    #
    #   In this case, we must also remove the "sha" attribute, since the
    #   lockfile should be force-diverged from the Berksfile
    #
    # @param [Hash] options
    #   the list of options to pass to the updater (see below for acceptable
    #   options)
    # @option options [Symbol, String, Array] :cookbooks
    #   List of cookbook names to update
    # @option options [Symbol, Array] :except
    #   Group(s) to exclude when updating
    # @option options [Symbol, Array] :only
    #   Group(s) to exclusively unlock for updating
    # @option options [String] :path
    #   a path to "vendor" the cached_cookbooks resolved by the resolver. Vendoring
    #   is a technique for packaging all cookbooks resolved by a Berksfile.
    #
    # @raise Berkshelf::BerksfileNotFound
    #   if the Berksfile cannot be found
    # @raise Berkshelf::ArgumentError
    #   if there are missing or conflicting options
    #
    # @return [Array<Berkshelf::CachedCookbook>]
    def self.update(options = {})
      @options = options

      ensure_berksfile!
      validate_options!

      # If no options were specified, then we are updating all cookbooks.
      # Otherwise, we lock all sources that haven't been specified.
      @locked_sources = options.empty? ? [] : (lockfile.sources - filter(lockfile.sources))

      # Update the lockfile with the new sources, change the SHA, and write out
      # the new lockfile.
      lockfile.update(@locked_sources)
      lockfile.sha = nil
      lockfile.save

      # Reset the filter options, because we don't want them to be excluded
      # during the installation.
      options.delete(:cookbooks)
      options.delete(:only)
      options.delete(:except)

      # Delegate all other responsible to the {Berkshelf::Installer}
      ::Berkshelf::Installer.install(options)
    end

  end
end
