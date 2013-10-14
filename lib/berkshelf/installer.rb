module Berkshelf
  class Installer
    extend Forwardable

    attr_reader :berksfile
    attr_reader :downloader

    def_delegator :berksfile, :lockfile

    # @param [Berkshelf::Berksfile] berksfile
    def initialize(berksfile)
      @berksfile  = berksfile
      @downloader = Downloader.new(berksfile)
    end

    def build_universe
      berksfile.sources.map(&:universe)
    end

    # @option options [Array<String>, String] cookbooks
    #
    # @return [Array<Berkshelf::CachedCookbook>]
    def run(options = {})
      dependencies = lockfile_reduce(berksfile.dependencies(options.slice(:except, :only)))
      resolver     = Resolver.new(berksfile, dependencies)

      dependencies.each do |dependency|
        next unless dependency.scm_location?
        Berkshelf.formatter.fetch(dependency)
        downloader.download(dependency)
      end

      dependencies.each do |dependency|
        next unless dependency.cached_cookbook
        resolver.add_explicit_dependencies(dependency)
      end

      Berkshelf.formatter.msg("building universe...")
      build_universe

      lock_deps = []

      cached_cookbooks = resolver.resolve.collect do |name, version, dependency|
        lock_deps << dependency
        dependency.locked_version ||= Solve::Version.new(version)
        if dependency.downloaded?
          Berkshelf.formatter.use(dependency.name, dependency.cached_cookbook.version, dependency.location)
          dependency.cached_cookbook
        else
          source = berksfile.sources.find { |source| source.cookbook(name, version)}
          remote_cookbook = source.cookbook(name, version)
          Berkshelf.formatter.install(name, version, dependency, source.to_s, remote_cookbook.location_path)
          temp_filepath = downloader.download(name, version)
          CookbookStore.import(name, version, temp_filepath)
        end
      end

      verify_licenses!(lock_deps)
      lockfile.update(lock_deps)
      cached_cookbooks
    end

    # Verify that the licenses of all the cached cookbooks fall in the realm of
    # allowed licenses from the Berkshelf Config.
    #
    # @param [Array<Berkshelf::Dependencies>] dependencies
    #
    # @raise [Berkshelf::LicenseNotAllowed]
    #   if the license is not permitted and `raise_license_exception` is true
    def verify_licenses!(dependencies)
      licenses = Array(Berkshelf.config.allowed_licenses)
      return if licenses.empty?

      dependencies.each do |dependency|
        next if dependency.location.is_a?(Berkshelf::PathLocation)
        cached = dependency.cached_cookbook

        begin
          unless licenses.include?(cached.metadata.license)
            raise Berkshelf::LicenseNotAllowed.new(cached)
          end
        rescue Berkshelf::LicenseNotAllowed => e
          if Berkshelf.config.raise_license_exception
            FileUtils.rm_rf(cached.path)
            raise
          end

          Berkshelf.ui.warn(e.to_s)
        end
      end
    end

    private

      def dependency_from_lockfile(dependency)
        locked = lockfile.find(dependency)

        return nil unless locked

        # If there's a locked_version, make sure it's still satisfied
        # by the constraint
        if locked.locked_version
          unless dependency.version_constraint.satisfies?(locked.locked_version)
            raise Berkshelf::OutdatedDependency.new(locked, dependency)
          end
        end

        # Update to the constraint to be a hard one
        locked.version_constraint = Solve::Constraint.new(locked.locked_version.to_s)
        locked
      end

      # Merge the locked dependencies against the given dependencies.
      #
      # For each the given dependencies, check if there's a locked version that
      # still satisfies the version constraint. If it does, "lock" that dependency
      # because we should just use the locked version.
      #
      # If a locked dependency exists, but doesn't satisfy the constraint, raise a
      # {Berkshelf::OutdatedDependency} and tell the user to run update.
      #
      # Never use the locked constraint for a dependency with a {PathLocation}
      #
      # @param [Array<Berkshelf::Dependency>] dependencies
      #
      # @return [Array<Berkshelf::Dependency>]
      def lockfile_reduce(dependencies = [])
        dependencies.collect do |dependency|
          if dependency.path_location?
            dependency
          else
            dependency_from_lockfile(dependency) || dependency
          end
        end
      end

      # The list of dependencies "locked" by the lockfile.
      #
      # @return [Array<Berkshelf::Dependency>]
      #   the list of dependencies in this lockfile
      def locked_dependencies
        lockfile.dependencies
      end

      def reduce_scm_locations(dependencies)
        dependencies.select { |dependency| SCM_LOCATIONS.include?(dependency.class.location_key) }
      end
  end
end
