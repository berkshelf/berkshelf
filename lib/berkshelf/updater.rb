module Berkshelf
  # This class is responsible for updating installed cookbooks
  #
  # @author Seth Vargo <sethvargo@gmail.com>
  # @author Jamie Winsor <reset@riotgames.com>
  class Updater
    class << self
      # @param [Berkshelf::Berksfile] berksfile
      # @param [Hash] options
      #   @see {Updater#update}
      def update(berksfile, options = {})
        new(berksfile).update(options)
      end
    end

    extend Forwardable

    attr_reader :berksfile

    def_delegator :berksfile, :lockfile

    # @param [Berkshelf::Berksfile] berksfile
    def initialize(berksfile)
      @berksfile = berksfile
    end

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
    # @option opts [Symbol, String, Array] :cookbooks
    #   List of cookbook names to update
    # @option opts [Symbol, Array] :except
    #   Group(s) to exclude when updating
    # @option opts [Symbol, Array] :only
    #   Group(s) to exclusively unlock for updating
    # @option opts [String] :path
    #   a path to "vendor" the cached_cookbooks resolved by the resolver. Vendoring
    #   is a technique for packaging all cookbooks resolved by a Berksfile.
    #
    # @raise Berkshelf::BerksfileNotFound
    #   if the Berksfile cannot be found
    # @raise Berkshelf::ArgumentError
    #   if there are missing or conflicting options
    #
    # @return [Array<Berkshelf::CachedCookbook>]
    #
    # @todo Support sources with :path, :git, and :github options
    def update(options = {})
      if options[:except] && options[:only]
        raise ArgumentError, "Cannot specify both :except and :only"
      end

      locked_sources = (lockfile.sources - Berksfile.filter_sources(lockfile.sources, options))

      lockfile.update(locked_sources)
      lockfile.sha = nil
      lockfile.save

      # Reset the filter options, because we don't want them to be excluded
      # during the installation.
      options.delete(:cookbooks)
      options.delete(:only)
      options.delete(:except)

      # Delegate all other responsible to the {Berkshelf::Installer}
      Installer.install(berksfile, options)
    end
  end
end
