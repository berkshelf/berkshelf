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
      @worker     = Worker.pool(size: [(Celluloid.cores.to_i - 1), 2].max, args: [berksfile])
    end

    def build_universe
      berksfile.sources.collect do |source|
        Thread.new do
          begin
            Berkshelf.formatter.msg("Fetching cookbook index from #{source.uri}...")
            source.build_universe
          rescue Berkshelf::APIClientError => ex
            Berkshelf.formatter.warn "Error retrieving universe from source: #{source}"
            Berkshelf.formatter.warn "  * [#{ex.class}] #{ex}"
          end
        end
      end.map(&:join)
    end

    # @return [Array<Berkshelf::CachedCookbook>]
    def run
      lockfile.reduce!

      Berkshelf.formatter.msg('Resolving cookbook dependencies...')

      dependencies, cookbooks = if lockfile.trusted?
        install_from_lockfile
      else
        install_from_universe
      end

      Berkshelf.log.debug "  Finished resolving, calculating locks"

      to_lock = dependencies.select do |dependency|
        berksfile.has_dependency?(dependency)
      end

      Berkshelf.log.debug "  New locks"
      to_lock.each do |lock|
        Berkshelf.log.debug "    #{lock}"
      end

      lockfile.graph.update(cookbooks)
      lockfile.update(to_lock)
      lockfile.save

      cookbooks
    end

    private

      attr_reader :worker

      class Worker
        include Celluloid

        attr_reader :berksfile
        attr_reader :downloader

        def initialize(berksfile)
          @berksfile  = berksfile
          @downloader = Downloader.new(berksfile)
        end

        # Install a specific dependency.
        #
        # @param [Dependency]
        #   the dependency to install
        # @return [CachedCookbook]
        #   the installed cookbook
        def install(dependency)
          Berkshelf.log.info "Installing #{dependency}"

          if dependency.installed?
            Berkshelf.log.debug "  Already installed - skipping install"

            Berkshelf.formatter.use(dependency)
            dependency.cached_cookbook
          else
            name, version = dependency.name, dependency.locked_version.to_s
            source = berksfile.source_for(name, version)

            # Raise error if our Berksfile.lock has cookbook versions that
            # can't be found in sources
            raise MissingLockfileCookbookVersion.new(name, version, 'in any of the sources') unless source

            Berkshelf.log.debug "  Downloading #{dependency.name} (#{dependency.locked_version}) from #{source}"

            cookbook = source.cookbook(name, version)

            Berkshelf.log.debug "    => #{cookbook.inspect}"

            Berkshelf.formatter.install(source, cookbook)

            downloader.download(name, version) do |stash|
              CookbookStore.import(name, version, stash)
            end
          end
        end
      end

      # Install all the dependencies from the lockfile graph.
      #
      # @return [Array<Array<Dependency> Array<CachedCookbook>>]
      #   the list of installed dependencies and cookbooks
      def install_from_lockfile
        Berkshelf.log.info "Installing from lockfile"

        dependencies = lockfile.graph.locks.values

        Berkshelf.log.debug "  Dependencies"
        dependencies.map do |dependency|
          Berkshelf.log.debug "    #{dependency}"
        end

        download_locations(dependencies)

        # Only construct the universe if we are going to install things
        unless dependencies.all?(&:installed?)
          Berkshelf.log.debug "  Not all dependencies are installed"
          build_universe
        end

        cookbooks = dependencies.sort.map { |dependency| worker.future.install(dependency) }.map(&:value)

        [dependencies, cookbooks]
      end

      # Resolve and install the dependencies from the "universe", updating the
      # lockfile appropiately.
      #
      # @return [Array<Array<Dependency> Array<CachedCookbook>>]
      #   the list of installed dependencies and cookbooks
      def install_from_universe
        Berkshelf.log.info "Installing from universe"

        dependencies = lockfile.graph.locks.values + berksfile.dependencies
        dependencies = dependencies.inject({}) do |hash, dependency|
          # Fancy way of ensuring no duplicate dependencies are used...
          hash[dependency.name] ||= dependency
          hash
        end.values

        download_locations(dependencies)

        Berkshelf.log.debug "  Creating a resolver"
        resolver = Resolver.new(berksfile, dependencies)

        # Unlike when installing from the lockfile, we _always_ need to build
        # the universe when installing from the universe... duh
        build_universe

        # Add any explicit dependencies for already-downloaded cookbooks (like
        # path locations)
        dependencies.each do |dependency|
          if dependency.location
            cookbook = dependency.cached_cookbook
            Berkshelf.log.debug "  Adding explicit dependency on #{cookbook}"
            resolver.add_explicit_dependencies(cookbook)
          end
        end

        Berkshelf.log.debug "  Starting resolution..."

        cookbooks = resolver.resolve.sort.map { |dependency| worker.future.install(dependency) }.map(&:value)

        [dependencies, cookbooks]
      end

      def download_locations(dependencies)
        dependencies.select(&:location).each do |dependency|
          unless dependency.location.installed?
            Berkshelf.formatter.fetch(dependency)
            dependency.location.install
          end
        end
      end
  end
end
