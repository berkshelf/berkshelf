require 'berkshelf/api-client'

module Berkshelf
  class Installer
    attr_reader :berksfile
    attr_reader :lockfile
    attr_reader :downloader

    # @param [Berkshelf::Berksfile] berksfile
    def initialize(berksfile)
      @berksfile  = berksfile
      @lockfile   = berksfile.lockfile
      @downloader = Downloader.new(berksfile)
    end

    def build_universe
      print 'Building universe...'

      berksfile.sources.collect do |source|
        Thread.new do
          begin
            print '.'
            source.build_universe
          rescue Berkshelf::APIClientError => ex
            Berkshelf.formatter.warn "Error retrieving universe from source: #{source}"
            Berkshelf.formatter.warn "  * [#{ex.class}] #{ex}"
          end
        end
      end.map(&:join)

      puts
    end

    # @return [Array<Berkshelf::CachedCookbook>]
    def run
      reduce_lockfile!

      cookbooks = if lockfile.trusted?
        install_from_lockfile
      else
        install_from_universe
      end

      lockfile.graph.update(cookbooks)
      lockfile.update_dependencies(berksfile.dependencies)
      lockfile.save

      verify_licenses!(cookbooks)

      cookbooks
    end

    # Install all the dependencies from the lockfile graph.
    #
    # @return [Array<CachedCookbook>]
    #   the list of installed cookbooks
    def install_from_lockfile
      locks = lockfile.graph.locks

      # Only construct the universe if we are going to download things
      unless locks.all? { |_, dependency| dependency.downloaded? }
        build_universe
      end

      locks.sort.collect do |name, dependency|
        install(dependency)
      end
    end

    # Resolve and install the dependencies from the "universe", updating the
    # lockfile appropiately.
    #
    # @return [Array<CachedCookbook>]
    #   the list of installed cookbooks
    def install_from_universe
      # Unlike when installing from the lockfile, we _always_ need to build
      # the universe when installing from the universe... duh
      build_universe

      dependencies = lockfile.graph.locks.values + berksfile.dependencies
      dependencies = dependencies.inject({}) do |hash, dependency|
        # Fancy way of ensuring no duplicate dependencies are used...
        hash[dependency.name] ||= dependency
        hash
      end.values

      resolver = Resolver.new(berksfile, dependencies)

      # Download all SCM locations first, since they might have additional
      # constraints that we don't yet know about
      dependencies.select(&:scm_location?).each do |dependency|
        Berkshelf.formatter.fetch(dependency)
        downloader.download(dependency)
      end

      # Add any explicit dependencies for already-downloaded cookbooks (like
      # path locations)
      dependencies.each do |dependency|
        if cookbook = dependency.cached_cookbook
          resolver.add_explicit_dependencies(cookbook)
        end
      end

      resolver.resolve.sort.collect do |dependency|
        install(dependency)
      end
    end

    # Install a specific dependency.
    #
    # @param [Dependency]
    #   the dependency to install
    # @return [CachedCookbook]
    #   the installed cookbook
    def install(dependency)
      if dependency.downloaded?
        Berkshelf.formatter.use(dependency)
        dependency.cached_cookbook
      else
        # Berkshelf.formatter.install()
        puts "Installing #{dependency}..."

        name, version = dependency.name, dependency.locked_version.to_s
        source   = berksfile.source_for(name, version)
        cookbook = source.cookbook(name, version)
        stash    = downloader.download(name, version)

        CookbookStore.import(name, version, stash)
      end
    end

    # Verify that the licenses of all the cached cookbooks fall in the realm of
    # allowed licenses from the Berkshelf Config.
    #
    # @param [Array<CachedCookbook>] cookbooks
    #
    # @raise [LicenseNotAllowed]
    #   if the license is not permitted and `raise_license_exception` is true
    #
    # @return [true]
    def verify_licenses!(cookbooks)
      licenses = Array(Berkshelf.config.allowed_licenses)
      return true if licenses.empty?

      cookbooks.each do |cookbook|
        begin
          unless licenses.include?(cookbook.metadata.license)
            raise Berkshelf::LicenseNotAllowed.new(cookbook)
          end
        rescue Berkshelf::LicenseNotAllowed => e
          if Berkshelf.config.raise_license_exception
            FileUtils.rm_rf(cookbook.path)
            raise
          end

          Berkshelf.ui.warn(e.to_s)
        end
      end

      true
    end

    private

    # Iterate over each top-level dependency defined in the lockfile and
    # check if that dependency is still defined in the Berksfile.
    #
    # If the dependency is no longer present in the Berksfile, it is "safely"
    # removed using {Lockfile#unlock} and {Lockfile#remove}. This prevents
    # the lockfile from "leaking" dependencies when they have been removed
    # from the Berksfile, but still remained locked in the lockfile.
    #
    # If the dependency exists, a constraint comparison is conducted to verify
    # that the locked dependency still satisifes the original constraint. This
    # handles the edge case where a user has updated or removed a constraint
    # on a dependency that already existed in the lockfile.
    #
    # @raise [OutdatedDependency]
    #   if the constraint exists, but is no longer satisifed by the existing
    #   locked version
    #
    # @return [Array<Dependency>]
    def reduce_lockfile!
      lockfile.dependencies.each do |dependency|
        if berksfile.dependencies.map(&:name).include?(dependency.name)
          locked = lockfile.graph.find(dependency)
          next if locked.nil?

          unless dependency.version_constraint.satisfies?(locked.version)
            raise OutdatedDependency.new(locked, dependency)
          end
        else
          lockfile.unlock(dependency)
        end
      end

      lockfile.save
    end
  end
end
