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
    def run(options = {})
      dependencies = lockfile_reduce(berksfile.dependencies(options.slice(:except, :only))

      dependencies.each do |dependency|
        next unless dependency.scm_location?
        Berkshelf.formatter.fetch(dependency)
        downloader.download(dependency)
      end

      Berkshelf.formatter.msg("building universe...")
      build_universe

      resolve(dependencies).each do |name, version, dependency|
        if dependency.downloaded?
          Berkshelf.formatter.use(dependency.name, dependency.cached_cookbook.version, dependency.location)
        else
          Berkshelf.formatter.install(name, version, dependency)
          temp_filepath = downloader.download(name, version)
          CookbookStore.import(name, version, temp_filepath)
        end
      end

      verify_licenses!
      lockfile.update(dependencies)
    end

    # Finds a solution for the Berksfile and returns an array of CachedCookbooks.
    #
    # @param [Array<Berkshelf::Dependency>, Berkshelf::Dependency] demands
    #   A dependency, or an array of dependencies to satisfy
    #
    # @return [Array<Berkshelf::CachedCookbooks>]
    def resolve(dependencies)
      Resolver.new(berksfile, dependencies).resolve
    end

    # Verify that the licenses of all the cached cookbooks fall in the realm of
    # allowed licenses from the Berkshelf Config.
    #
    # @raise [Berkshelf::LicenseNotAllowed]
    #   if the license is not permitted and `raise_license_exception` is true
    def verify_licenses!
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
        locked_dependency = lockfile.find(dependency)

        return nil unless locked_dependency

        # If there's a locked_version, make sure it's still satisfied
        # by the constraint
        if locked_dependency.locked_version
          unless dependency.version_constraint.satisfies?(locked_dependency.locked_version)
            raise Berkshelf::OutdatedDependency.new(locked_dependency, dependency)
          end
        end

        # Update to the new constraint (it might have changed, but still be satisfied)
        locked_dependency.version_constraint = dependency.version_constraint
        locked_dependency
      end

      # Merge the locked dependencies against the given dependencies.
      #
      # For each the given dependencies, check if there's a locked version that
      # still satisfies the version constraint. If it does, "lock" that dependency
      # because we should just use the locked version.
      #
      # If a locked dependency exists, but doesn't satisfy the constraint, raise a
      # {Berkshelf::OutdatedDependency} and tell the user to run update.
      def lockfile_reduce(dependencies = [])
        dependencies.collect do |dependency|
          dependency_from_lockfile(dependency) || dependency
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
