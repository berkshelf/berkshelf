module Berkshelf
  # Responsible for installing cookbooks
  #
  # @author Seth Vargo <sethvargo@gmail.com>
  # @author Jamie Winsor <reset@riotgames.com>
  class Installer
    class << self
      # @param [Berkshelf::Berksfile] berksfile
      # @param [Hash] options
      #   @see {Installer#install}
      def install(berksfile, options = {})
        new(berksfile).install(options)
      end

      # Copy all cached_cookbooks to the given directory. Each cookbook will
      # be contained in a directory named after the name of the cookbook.
      #
      # @param [Array<Berkshelf::CachedCookbook>] cookbooks
      #   an array of CachedCookbooks to be copied to a vendor directory
      # @param [String] path
      #
      # @return [String]
      #   expanded filepath to the vendor directory
      def vendor(cookbooks, path)
        path = File.expand_path(path)

        chefignore_file = [
          File.join(Dir.pwd, 'chefignore'),
          File.join(Dir.pwd, 'cookbooks', 'chefignore')
        ].find { |f| File.exists?(f) }

        chefignore = chefignore_file && ::Chef::Cookbook::Chefignore.new(chefignore_file)
        FileUtils.mkdir_p(path)

        scratch = Berkshelf.mktmpdir
        cookbooks.each do |cookbook|
          dest = File.join(scratch, cookbook.cookbook_name, '/')
          FileUtils.mkdir_p(dest)

          # Dir.glob does not support backslash as a File separator
          src = cookbook.path.to_s.gsub('\\', '/')
          files = Dir.glob(File.join(src, '*'))

          # Filter out files using chefignore
          files = chefignore.remove_ignores_from(files) if chefignore

          FileUtils.cp_r(files, dest)
        end

        FileUtils.remove_dir(path, force: true)
        FileUtils.mv(scratch, path)

        path
      end
    end

    include Berkshelf::Command
    extend Forwardable

    attr_reader :berksfile

    def_delegator :berksfile, :lockfile

    # @param [Berkshelf::Berksfile] berksfile
    def initialize(berksfile)
      @berksfile = berksfile
    end

    # Install the sources listed in the Berksfile, respecting the locked
    # versions in the Berksfile.lock.
    #
    # 1. Check for the existence of the Berkshelf path (<tt>~/.berkshelf</tt>
    #    by default). If it's not there, it will be created.
    #
    # 2. Check for the existence of a Berksfile. If the file is not there, a
    #    {Berkshelf::BerksfileNotFound} is raised.
    #
    # 3. Check that the Berksfile has content (i.e. has at least one cookbook
    #    source definition).
    #
    # 4. Check that a lockfile exists. If a lockfile does not exist, all
    #    sources are considered to be "unlocked". If a lockfile is specified, a
    #    definition is created via the following algorithm:
    #
    #    - Compare the SHA of the current Berksfile with the last-known SHA.
    #    - If the SHAs match, the Berksfile has not been updated, so we rely
    #      solely on the locked sources.
    #    - If the SHAs don't match, then the Berksfile has diverged from the
    #      lockfile, which means some sources are outdated. For each unlocked
    #      source, see if there exists a locked version that still satisfies
    #      the version constraint in the Berksfile. If there exists such a
    #      source, remove it from the list of unlocked sources. If not, then
    #      either a version constraint has changed, or a new source has been
    #      added to the Berksfile. In the event that a locked_source exists,
    #      but it no longer satisfies the constraint, this method will raise
    #      a {Berkshelf::OutdatedCookbookSource}, and inform the user to run
    #      <tt>berks update COOKBOOK</tt> to remedy the issue.
    #    - Remove any locked sources that no longer exist in the Berksfile
    #      (i.e. a cookbook source was removed from the Berksfile).
    #
    # 5. Resolve the collection of locked and unlocked sources.
    #
    # 6. Write out a new lockfile.
    #
    # @option options [Symbol, Array] :except
    #   Group(s) to exclude which will cause any sources marked as a member of the
    #   group to not be installed
    # @option options [Symbol, Array] :only
    #   Group(s) to include which will cause any sources marked as a member of the
    #   group to be installed and all others to be ignored
    # @option options [String] :path
    #   a path to "vendor" the cached_cookbooks resolved by the resolver. Vendoring
    #   is a technique for packaging all cookbooks resolved by a Berksfile.
    #
    # @raise [Berkshelf::OutdatedCookbookSource]
    #   if the lockfile constraints do not satisfy the Berskfile constraints
    #
    # @return [Array<Berkshelf::CachedCookbook>]
    def install(options = {})
      validate_options!(options)

      # The sources begin as those in our berksfile. We will eventually shorten
      # replace some of these sources with their locked versions.
      @sources = filter(berksfile.sources)

      # Get a list of our locked sources. This will be an empty array in the
      # absence of a lockfile.
      @locked_sources = lockfile.sources

      # If the SHAs match, then the lockfile is in up-to-date with the Berksfile.
      # We can rely solely on the lockfile.
      if berksfile.sha == lockfile.sha
        @sources = @locked_sources
      else
        # Since the SHAs were different, we need to determine which sources
        # have diverged from the lockfile.
        #
        # For all of our unlocked sources, check if there's a locked version that
        # still satisfies the version constraint. If it does, "lock" that source
        # because we should just use the locked version.
        #
        # If a locked source exists, but doesn't satisfy the constraint, raise a
        # {Berkshelf::OutdatedCookbookSource} and instruct the user to run
        # <tt>berks update</tt>.
        @sources.collect! do |source|
          locked_source = @locked_sources.find{ |s| s.name == source.name }

          if locked_source
            if source.version_constraint.satisfies?(locked_source.locked_version)
              locked_source
            else
              raise ::Berkshelf::OutdatedCookbookSource, "The current lockfile has #{locked_source.name} locked at #{locked_source.locked_version}.\nTry running `berks update #{locked_source.name}`"
            end
          else
            source
          end
        end
      end

      # Create a solution from the sources. These sources are both specifically
      # locked versions and version constraints.
      resolve, sources = resolve(@sources)

      if options[:path]
        self.class.vendor(resolve, options[:path])
      end

      # Now we need to remove files from our locked sources, since we have no
      # way of detecting that a source was removed. We also only want to lock
      # versions that are in the Berksfile (i.e. don't lock dependency
      # versions)
      cookbooks = berksfile.sources.map(&:name)
      locked_sources = sources.select { |source| cookbooks.include?(source.name) }

      # Update the lockfile with the locked sources
      lockfile.update(locked_sources)
      lockfile.sha = berksfile.sha
      lockfile.save
    end

    private

      # Resolve the collection of sources using {Berkshelf::Resolver}.
      #
      # @param [Array<Berkshelf::CookbookSource>] sources
      #   the list of sources to resolve
      # @return [Array<Berkshelf::CachedCookbook, Berkshelf::CookbookSource>]
      #   a collection of the resolved {Berkshelf::CachedCookbook}s (index 0) and
      #   {Berkshelf::CookbookSource}s (index 1)
      def resolve(sources)
        resolver = Resolver.new(
          Downloader.new(Berkshelf.cookbook_store),
          sources: sources
        )

        [resolver.resolve, resolver.sources]
      end
  end
end
