module Berkshelf
  # This class is responsible for installing cookbooks and handling the
  # `berks install` command.
  #
  # @author Seth Vargo <sethvargo@gmail.com>
  class Installer
    class << self
      # 0. Check for the presence of the ~/.berkshelf directory
      # 1. Check for the presence of a Berksfile
      # 2. Check that the Berksfile has content
      # 3. Check if the lockfile exists
      # 4. Create a definition from the lockfile and berksfile
      # 5. Resolve the dependencies locally or remotely
      # 6. Generate a new lockfile
      def install(options = {})
        @options = options

        ensure_berkshelf_directory!
        ensure_berksfile!
        ensure_berksfile_content!

        # The "unlocked" cookbooks begins as the sources in our berksfile. We will
        # eventually shorten this array if there's a lockfile.
        @unlocked_sources = berksfile.sources

        if lockfile
          @locked_sources = lockfile.sources

          # If the SHAs match, then the lockfile is in up-to-date with the Berksfile.
          # We can rely solely on the lockfile.
          if berksfile.sha == lockfile.sha
            @unlocked_sources = []
          else
            # Since the SHAs were different, we need to determine which sources
            # have diverged from the lockfile.
            #
            # For all of our unlocked sources, check if there's a local version that
            # still satisfies the version constraint. If it does, "lock" that source
            # because we should just use the locked version.
            @unlocked_sources.reject! do |source|
              locked_source = @locked_sources.find{ |s| s.name == source.name }
              # p source
              # p source.version_constraint
              # puts
              # p locked_source
              # p locked_source.locked_version
              # puts
              # puts
              # puts
              locked_source && source.version_constraint.satisfies?(locked_source.locked_version)
            end

            # Now we need to remove files from our locked sources, since we have no
            # way of detecting that a source was removed.
            @locked_sources &= @unlocked_sources
          end
        end

        resolve, sources = resolve(@unlocked_sources + @locked_sources)

        lockfile.update(sources)
        lockfile.save
      end

      private
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
      # @raises [Berkshelf::BerksfileNotFound]
      #   if the file is not found
      #
      # @return [Berkshelf::Berksfile]
      #   the current Berksfile
      def berksfile
        @berksfile ||= ::Berkshelf::Berksfile.from_file(options[:berksfile])
      end

      def resolve(sources)
        resolver = Resolver.new(
          Downloader.new(Berkshelf.cookbook_store),
          sources: sources
        )

        [resolver.resolve, resolver.sources]
      end

    end
  end
end
