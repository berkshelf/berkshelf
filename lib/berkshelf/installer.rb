module Berkshelf
  # This class is responsible for installing cookbooks and handling the
  # `berks install` command.
  #
  # @author Seth Vargo <sethvargo@gmail.com>
  class Installer
    class << self
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
      # @param [Hash] options
      #   the list of options to pass to the installer (see below for acceptable
      #   options)
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
      # @raise Berkshelf::OutdatedCookbookSource
      #   if the lockfile constraints do not satisfy the Berskfile constraints
      # @raise Berkshelf::ArgumentError
      #   if there are missing or conflicting options
      #
      # @return [Array<Berkshelf::CachedCookbook>]
      def install(options = {})
        @options = options

        validate_options!
        ensure_berkshelf_directory!
        ensure_berksfile!
        ensure_berksfile_content!

        # The sources begin as those in our berksfile. We will eventually shorten
        # replace some of these sources with their locked versions.
        @sources = berksfile.sources

        # Assume there are no locked_sources to start
        @locked_sources = []

        if lockfile
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
                  raise ::Berkshelf::OutdatedCookbookSource, "The current lockfile has #{locked_source.name} locked at #{locked_source.version}.\nTry running `berks update #{locked_source.name}`"
                end
              else
                source
              end
            end
          end
        end

        # Create a solution from the sources. These sources are both specifically
        # locked versions and version constraints.
        resolve, sources = resolve(@sources)

        # Now we need to remove files from our locked sources, since we have no
        # way of detecting that a source was removed. We also only want to lock
        # versions that are in the Berksfile (i.e. don't lock dependency
        # versions)
        cookbooks = berksfile.sources.map(&:name)
        locked_sources = sources.select{ |source| cookbooks.include?(source.name) }

        # Update the lockfile with the locked sources
        lockfile.update(locked_sources)
        lockfile.sha = berksfile.sha
        lockfile.save
      end

      private
      # Validate the options hash, ensuring there are no conflicting arguments
      #
      # @raise Berkshelf::ArgumentError
      #   if there are conflicting or invalid options
      def validate_options!
        if options[:except] && options[:only]
          raise Berkshelf::ArgumentError, "Cannot specify both :except and :only"
        end

        if options[:cookbooks] && (options[:except] || options[:only])
          options[:except], options[:only] = [], []
          ::Berkshelf.ui.warn "Cookbooks were specified, ignoring `:except` and `:only` arguments"
        end
      end

      # Ensure the berkshelf directory is created and accessible.
      def ensure_berkshelf_directory!
        unless ::File.exists?(Berkshelf.berkshelf_path)
          ::FileUtils.mkdir_p(Berkshelf.berkshelf_path)
        end
      end

      # Check for the presence of a Berksfile. Berkshelf cannot do anything
      # without the presence of a Berksfile.lock.
      def ensure_berksfile!
        unless ::File.exists?(Berkshelf::DEFAULT_FILENAME)
          raise ::Berkshelf::BerksfileNotFound, "No #{options[:berksfile]} was found at ."
        end
      end

      # Check that the Berksfile has content. If the Berksfile is empty, raise
      # an exception to require at least one definition.
      def ensure_berksfile_content!
        begin
          unless ::File.read(Berkshelf::DEFAULT_FILENAME).size > 1
            raise Berksfile::BerksfileNotFound, "Your #{Berkshelf::DEFAULT_FILENAME} is empty! You need at least one cookbook definition."
          end
        rescue Errno::ENOENT
          ensure_berksfile!
        end
      end

      # @return [Hash]
      #   the options for this installer
      def options
        @options ||= {}
      end

      # Attempt to load and parse the lockfile associated with this berksfile.
      #
      # @return [Berkshelf::Lockfile, nil]
      #   the lockfile for the current berksfile
      def lockfile
        @lockfile ||= berksfile.lockfile
      end

      # Load the Berksfile for the current project.
      #
      # @raise [Berkshelf::BerksfileNotFound]
      #   if the file is not found
      #
      # @return [Berkshelf::Berksfile]
      #   the current Berksfile
      def berksfile
        @berksfile ||= ::Berkshelf::Berksfile.from_file(options[:berksfile])
      end

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

      # Filter the list of sources from the options passed to the installer.
      #
      # @param [Array<Berkshelf::CookbookSource>] sources
      #   the list of sources to resolve
      #
      # @raise [Berkshelf::ArgumentError] if a value for both :except and :only is provided
      #
      # @return [Array<Berkshelf::CookbookSource>]
      def filter(sources)
        cookbooks = Array(options[:cookbooks])
        except    = Array(options[:except]).map(&:to_sym)
        only      = Array(options[:only]).map(&:to_sym)

        case
        when !cookbooks.empty?
          sources.select { |source| cookbooks.include?(source.name) }
        when !except.empty?
          sources.select { |source| (except & source.groups).empty? }
        when !only.empty?
          sources.select { |source| !(only & source.groups).empty? }
        else
          sources
        end
      end

    end
  end
end
