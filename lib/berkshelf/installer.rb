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
