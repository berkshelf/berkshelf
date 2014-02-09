require 'berkshelf/api-client'

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
      berksfile.sources.collect do |source|
        Thread.new do
          begin
            source.build_universe
          rescue Berkshelf::APIClientError => ex
            Berkshelf.formatter.warn "Error retrieving universe from source: #{source}"
            Berkshelf.formatter.warn "  * [#{ex.class}] #{ex}"
          end
        end
      end.map(&:join)
    end

    # @option options [Array<String>, String] cookbooks
    #
    # @return [Array<Berkshelf::CachedCookbook>]
    def run(options = {})
      dependencies = lockfile_reduce(berksfile.dependencies)
      resolver     = Resolver.new(berksfile, dependencies)
      lock_deps    = []

      dependencies.each do |dependency|
        if dependency.scm_location?
          Berkshelf.formatter.fetch(dependency)
          downloader.download(dependency)
        end

        next if (cookbook = dependency.cached_cookbook).nil?

        resolver.add_explicit_dependencies(cookbook)
      end

      Berkshelf.formatter.msg("building universe...")
      build_universe

      cached_cookbooks = resolver.resolve.collect do |name, version, dependency|
        lock_deps << dependency
        dependency.locked_version ||= Solve::Version.new(version)
        if dependency.downloaded?
          Berkshelf.formatter.use(dependency.name, dependency.cached_cookbook.version, dependency.location)
          dependency.cached_cookbook
        else
          source = berksfile.sources.find { |source| source.cookbook(name, version) }
          remote_cookbook = source.cookbook(name, version)
          Berkshelf.formatter.install(name, version, api_source: source, location_type: remote_cookbook.location_type,
            location_path: remote_cookbook.location_path)
          temp_filepath = downloader.download(name, version)
          CookbookStore.import(name, version, temp_filepath)
        end
      end

      verify_licenses!(lock_deps)

      lockfile.update_graph(cached_cookbooks)
      lockfile.update_dependencies(berksfile.dependencies)
      lockfile.save

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

      # Returns an instance of `Berkshelf::Dependency` with an equality constraint matching
      # the locked version of the dependency in the lockfile.
      #
      # If no matching dependency is found in the lockfile then nil is returned.
      #
      # @param [Berkshelf:Dependency] dependency
      #
      # @return [Berkshelf::Dependency, nil]
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
        {}.tap do |h|
          (dependencies + lockfile.dependencies).each do |dependency|
            next if h.has_key?(dependency.name)

            if dependency.path_location?
              result = dependency
            else
              result = dependency_from_lockfile(dependency) || dependency
            end

            h[result.name] = result
          end
        end.values
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
