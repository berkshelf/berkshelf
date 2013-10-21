module Berkshelf
  class Berksfile
    class << self
      # @param [#to_s] file
      #   a path on disk to a Berksfile to instantiate from
      #
      # @return [Berksfile]
      def from_file(file)
        raise BerksfileNotFound.new(file) unless File.exist?(file)

        begin
          new(file).dsl_eval_file(file)
        rescue => ex
          raise BerksfileReadError.new(ex)
        end
      end

      # Copy all cached_cookbooks to the given directory. Each cookbook will be contained in
      # a directory named after the name of the cookbook.
      #
      # @param [Array<CachedCookbook>] cookbooks
      #   an array of CachedCookbooks to be copied to a vendor directory
      # @param [String] path
      #   filepath to vendor cookbooks to
      #
      # @return [String]
      #   expanded filepath to the vendor directory
      def vendor(cookbooks, path)
        chefignore = nil
        path       = File.expand_path(path)
        scratch    = Berkshelf.mktmpdir

        FileUtils.mkdir_p(path)

        unless (ignore_file = Berkshelf::Chef::Cookbook::Chefignore.find_relative_to(Dir.pwd)).nil?
          chefignore = Berkshelf::Chef::Cookbook::Chefignore.new(ignore_file)
        end

        cookbooks.each do |cb|
          dest = File.join(scratch, cb.cookbook_name, '/')
          FileUtils.mkdir_p(dest)

          # Dir.glob does not support backslash as a File separator
          src = cb.path.to_s.gsub('\\', '/')
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

    include Berkshelf::Mixin::Logging
    include Berkshelf::Mixin::DSLEval
    extend Forwardable

    expose_method :metadata
    expose_method :group
    expose_method :site
    expose_method :chef_api
    expose_method :cookbook

    @@active_group = nil

    # @return [String]
    #   The path on disk to the file representing this instance of Berksfile
    attr_reader :filepath

    # @return [Berkshelf::Downloader]
    attr_reader :downloader

    # @return [Array<Berkshelf::CachedCookbook>]
    attr_reader :cached_cookbooks

    def_delegator :downloader, :add_location
    def_delegator :downloader, :locations

    # @param [String] path
    #   path on disk to the file containing the contents of this Berksfile
    def initialize(path)
      @filepath         = path
      @sources          = Hash.new
      @downloader       = Downloader.new(Berkshelf.cookbook_store)
      @cached_cookbooks = nil
    end

    # Add a cookbook dependency to the Berksfile to be retrieved and have it's dependencies recursively retrieved
    # and resolved.
    #
    # @example a cookbook source that will be retrieved from one of the default locations
    #   cookbook 'artifact'
    #
    # @example a cookbook source that will be retrieved from a path on disk
    #   cookbook 'artifact', path: '/Users/reset/code/artifact'
    #
    # @example a cookbook source that will be retrieved from a remote community site
    #   cookbook 'artifact', site: 'http://cookbooks.opscode.com/api/v1/cookbooks'
    #
    # @example a cookbook source that will be retrieved from the latest API of the Opscode Community Site
    #   cookbook 'artifact', site: :opscode
    #
    # @example a cookbook source that will be retrieved from a Git server
    #   cookbook 'artifact', git: 'git://github.com/RiotGames/artifact-cookbook.git'
    #
    # @example a cookbook source that will be retrieved from a Chef API (Chef Server)
    #   cookbook 'artifact', chef_api: 'https://api.opscode.com/organizations/vialstudios',
    #     node_name: 'reset', client_key: '/Users/reset/.chef/knife.rb'
    #
    # @example a cookbook source that will be retrieved from a Chef API using your Berkshelf config
    #   cookbook 'artifact', chef_api: :config
    #
    # @overload cookbook(name, version_constraint, options = {})
    #   @param [#to_s] name
    #   @param [#to_s] version_constraint
    #   @param [Hash] options
    #
    #   @option options [Symbol, Array] :group
    #     the group or groups that the cookbook belongs to
    #   @option options [String, Symbol] :chef_api
    #     a URL to a Chef API. Alternatively the symbol :config can be provided
    #     which will instantiate this location with the values found in your
    #     Berkshelf configuration.
    #   @option options [String] :site
    #     a URL pointing to a community API endpoint
    #   @option options [String] :path
    #     a filepath to the cookbook on your local disk
    #   @option options [String] :git
    #     the Git URL to clone
    #
    #   @see ChefAPILocation
    #   @see SiteLocation
    #   @see PathLocation
    #   @see GitLocation
    # @overload cookbook(name, options = {})
    #   @param [#to_s] name
    #   @param [Hash] options
    #
    #   @option options [Symbol, Array] :group
    #     the group or groups that the cookbook belongs to
    #   @option options [String, Symbol] :chef_api
    #     a URL to a Chef API. Alternatively the symbol :config can be provided
    #     which will instantiate this location with the values found in your
    #     Berkshelf configuration.
    #   @option options [String] :site
    #     a URL pointing to a community API endpoint
    #   @option options [String] :path
    #     a filepath to the cookbook on your local disk
    #   @option options [String] :git
    #     the Git URL to clone
    #
    #   @see ChefAPILocation
    #   @see SiteLocation
    #   @see PathLocation
    #   @see GitLocation
    def cookbook(*args)
      options = args.last.is_a?(Hash) ? args.pop : Hash.new
      name, constraint = args

      options[:path] &&= File.expand_path(options[:path], File.dirname(filepath))
      options[:group] = Array(options[:group])

      if @@active_group
        options[:group] += @@active_group
      end

      add_source(name, constraint, options)
    end

    def group(*args)
      @@active_group = args
      yield
      @@active_group = nil
    end

    # Use a Cookbook metadata file to determine additional cookbook sources to retrieve. All
    # sources found in the metadata will use the default locations set in the Berksfile (if any are set)
    # or the default locations defined by Berkshelf.
    #
    # @param [Hash] options
    #
    # @option options [String] :path
    #   path to the metadata file
    def metadata(options = {})
      path = options[:path] || File.dirname(filepath)

      metadata_path = File.expand_path(File.join(path, 'metadata.rb'))
      metadata = Ridley::Chef::Cookbook::Metadata.from_file(metadata_path)

      name = metadata.name.presence || File.basename(File.expand_path(path))

      add_source(name, nil, { path: path, metadata: true })
    end

    # Add a 'Site' default location which will be used to resolve cookbook sources that do not
    # contain an explicit location.
    #
    # @note
    #   specifying the symbol :opscode as the value of the site default location is an alias for the
    #   latest API of the Opscode Community Site.
    #
    # @example
    #   site :opscode
    #   site "http://cookbooks.opscode.com/api/v1/cookbooks"
    #
    # @param [String, Symbol] value
    #
    # @return [Hash]
    def site(value)
      add_location(:site, value)
    end

    # Add a 'Chef API' default location which will be used to resolve cookbook sources that do not
    # contain an explicit location.
    #
    # @note
    #   specifying the symbol :config as the value of the chef_api default location will attempt to use the
    #   contents of your Berkshelf configuration to find the Chef API to interact with.
    #
    # @example using the symbol :config to add a Chef API default location
    #   chef_api :config
    #
    # @example using a URL, node_name, and client_key to add a Chef API default location
    #   chef_api 'https://api.opscode.com/organizations/vialstudios', node_name: 'reset',
    #     client_key: '/Users/reset/.chef/knife.rb'
    #
    # @param [String, Symbol] value
    # @param [Hash] options
    #
    # @return [Hash]
    def chef_api(value, options = {})
      add_location(:chef_api, value, options)
    end

    # Add a source of the given name and constraint to the array of sources.
    #
    # @param [String] name
    #   the name of the source to add
    # @param [String, Solve::Constraint] constraint
    #   the constraint to lock the source to
    # @param [Hash] options
    #
    # @raise [DuplicateSourceDefined] if a source is added whose name conflicts
    #   with a source who has already been added.
    #
    # @return [Array<Berkshelf::CookbookSource]
    def add_source(name, constraint = nil, options = {})
      if has_source?(name)
        # Only raise an exception if the source is a true duplicate
        groups = (options[:group].nil? || options[:group].empty?) ? [:default] : options[:group]
        if !(@sources[name].groups & groups).empty?
          raise DuplicateSourceDefined,
            "Berksfile contains multiple sources named '#{name}'. Use only one, or put them in different groups."
        end
      end

      if options[:path]
        metadata_file = File.join(options[:path], 'metadata.rb')
      end

      options[:constraint] = constraint

      @sources[name] = CookbookSource.new(self, name, options)
    end

    # @param [#to_s] source
    #   the source to remove
    #
    # @return [Berkshelf::CookbookSource]
    def remove_source(source)
      @sources.delete(source.to_s)
    end

    # @param [#to_s] source
    #   the source to check presence of
    #
    # @return [Boolean]
    def has_source?(source)
      @sources.has_key?(source.to_s)
    end

    # The list of cookbook sources specified in this Berksfile
    #
    # @param [Array] sources
    #   the list of sources to filter
    #
    # @option options [Symbol, Array] :except
    #   group(s) to exclude to exclude from the returned Array of sources
    #   group to not be installed
    # @option options [Symbol, Array] :only
    #   group(s) to include which will cause any sources marked as a member of the
    #   group to be installed and all others to be ignored
    # @option cookbooks [String, Array] :cookbooks
    #   names of the cookbooks to retrieve sources for
    #
    # @raise [Berkshelf::ArgumentError]
    #   if a value for both :except and :only is provided
    #
    # @return [Array<Berkshelf::CookbookSource>]
    #   the list of cookbook sources that match the given options
    def sources(options = {})
      l_sources = @sources.values

      cookbooks = Array(options[:cookbooks])
      except    = Array(options[:except]).collect(&:to_sym)
      only      = Array(options[:only]).collect(&:to_sym)

      case
      when !except.empty? && !only.empty?
        raise Berkshelf::ArgumentError, 'Cannot specify both :except and :only'
      when !cookbooks.empty?
        if !except.empty? && !only.empty?
          Berkshelf.ui.warn 'Cookbooks were specified, ignoring :except and :only'
        end
        l_sources.select { |source| cookbooks.include?(source.name) }
      when !except.empty?
        l_sources.select { |source| (except & source.groups).empty? }
      when !only.empty?
        l_sources.select { |source| !(only & source.groups).empty? }
      else
        l_sources
      end
    end

    # Find a source defined in this berksfile by name.
    #
    # @param [String] name
    #   the name of the cookbook source to search for
    # @return [Berkshelf::CookbookSource, nil]
    #   the cookbook source, or nil if one does not exist
    def find(name)
      @sources[name]
    end

    # @return [Hash]
    #   a hash containing group names as keys and an array of CookbookSources
    #   that are a member of that group as values
    #
    #   Example:
    #     {
    #       nautilus: [
    #         #<Berkshelf::CookbookSource: nginx (~> 1.0.0)>,
    #         #<Berkshelf::CookbookSource: mysql (~> 1.2.4)>
    #       ],
    #       skarner: [
    #         #<Berkshelf::CookbookSource: nginx (~> 1.0.0)>
    #       ]
    #     }
    def groups
      {}.tap do |groups|
        sources.each do |source|
          source.groups.each do |group|
            groups[group] ||= []
            groups[group] << source
          end
        end
      end
    end

    # @param [String] name
    #   name of the source to return
    #
    # @return [Berkshelf::CookbookSource]
    def [](name)
      @sources[name]
    end
    alias_method :get_source, :[]

    # Install the sources listed in the Berksfile, respecting the locked
    # versions in the Berksfile.lock.
    #
    # 1. Check that a lockfile exists. If a lockfile does not exist, all
    #    sources are considered to be "unlocked". If a lockfile is specified, a
    #    definition is created via the following algorithm:
    #
    #    - For each source, see if there exists a locked version that still
    #      satisfies the version constraint in the Berksfile. If
    #      there exists such a source, remove it from the list of unlocked
    #      sources. If not, then either a version constraint has changed,
    #      or a new source has been added to the Berksfile. In the event that
    #      a locked_source exists, but it no longer satisfies the constraint,
    #      this method will raise a {Berkshelf::OutdatedCookbookSource}, and
    #      inform the user to run <tt>berks update COOKBOOK</tt> to remedy the issue.
    #    - Remove any locked sources that no longer exist in the Berksfile
    #      (i.e. a cookbook source was removed from the Berksfile).
    #
    # 2. Resolve the collection of locked and unlocked sources.
    #
    # 3. Write out a new lockfile.
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
    # @option options [Boolean] :update_lockfile (true)
    #   a boolean method indicating whether we should update the lockfile
    #
    # @raise [Berkshelf::OutdatedCookbookSource]
    #   if the lockfile constraints do not satisfy the Berskfile constraints
    # @raise [Berkshelf::ArgumentError]
    #   if there are missing or conflicting options
    #
    # @return [Array<Berkshelf::CachedCookbook>]
    def install(options = {})
      local_sources = apply_lockfile(sources(options))

      resolver          = resolve(local_sources)
      @cached_cookbooks = resolver[:solution]
      local_sources     = resolver[:sources]

      verify_licenses!

      self.class.vendor(@cached_cookbooks, options[:path]) if options[:path]

      lockfile.update(local_sources) unless options[:update_lockfile] == false

      self.cached_cookbooks
    end

    # @option options [Symbol, Array] :except
    #   Group(s) to exclude which will cause any sources marked as a member of the
    #   group to not be installed
    # @option options [Symbol, Array] :only
    #   Group(s) to include which will cause any sources marked as a member of the
    #   group to be installed and all others to be ignored
    # @option cookbooks [String, Array] :cookbooks
    #   Names of the cookbooks to retrieve sources for
    def update(options = {})
      validate_cookbook_names!(options)

      # Unlock any/all specified cookbooks
      sources(options).each { |source| lockfile.unlock(source) }

      # NOTE: We intentionally do NOT pass options to the installer
      self.install
    end

    # Get a list of all the cookbooks which have newer versions found on the community
    # site versus what your current constraints allow
    #
    # @option options [Symbol, Array] :except
    #   Group(s) to exclude which will cause any sources marked as a member of the
    #   group to not be installed
    # @option options [Symbol, Array] :only
    #   Group(s) to include which will cause any sources marked as a member of the
    #   group to be installed and all others to be ignored
    # @option cookbooks [String, Array] :cookbooks
    #   Names of the cookbooks to retrieve sources for
    #
    # @return [Hash]
    #   a hash of cached cookbooks and their latest version. An empty hash is returned
    #   if there are no newer cookbooks for any of your sources
    #
    # @example
    #   berksfile.outdated => {
    #     #<CachedCookbook name="artifact"> => "0.11.2"
    #   }
    def outdated(options = {})
      outdated = Hash.new

      sources(options).each do |cookbook|
        location = cookbook.location || Location.init(cookbook.name, cookbook.version_constraint, site: :opscode)

        if location.is_a?(SiteLocation)
          latest_version = location.latest_version

          unless cookbook.version_constraint.satisfies?(latest_version)
            outdated[cookbook] = latest_version
          end
        end
      end

      outdated
    end

    # Upload the cookbooks installed by this Berksfile
    #
    # @option options [Boolean] :force (false)
    #   Upload the Cookbook even if the version already exists and is frozen on the
    #   target Chef Server
    # @option options [Boolean] :freeze (true)
    #   Freeze the uploaded Cookbook on the Chef Server so that it cannot be overwritten
    # @option options [Symbol, Array] :except
    #   Group(s) to exclude which will cause any sources marked as a member of the
    #   group to not be installed
    # @option options [Symbol, Array] :only
    #   Group(s) to include which will cause any sources marked as a member of the
    #   group to be installed and all others to be ignored
    # @option options [String, Array] :cookbooks
    #   Names of the cookbooks to retrieve sources for
    # @option options [Hash] :ssl_verify (true)
    #   Disable/Enable SSL verification during uploads
    # @option options [Boolean] :skip_dependencies (false)
    #   Skip uploading dependent cookbook(s).
    # @option options [Boolean] :halt_on_frozen (false)
    #   Raise a FrozenCookbook error if one of the cookbooks being uploaded is already located
    #   on the remote Chef Server and frozen.
    # @option options [String] :server_url
    #   An overriding Chef Server to upload the cookbooks to
    # @option options [String] :client_name
    #   An overriding client name to use for connecting to the chef server
    # @option options [String] :client_key
    #   An overriding client key to use for connecting to the chef server
    #
    # @raise [UploadFailure]
    #   if you are uploading cookbooks with an invalid or not-specified client key
    # @raise [Berkshelf::FrozenCookbook]
    #   if an attempt to upload a cookbook which has been frozen on the target server is made
    #   and the :halt_on_frozen option was true
    def upload(options = {})
      options = options.reverse_merge(force: false, freeze: true, skip_dependencies: false, halt_on_frozen: false, update_lockfile: false, validate: true)

      cached_cookbooks = install(options)
      upload_opts      = options.slice(:force, :freeze, :validate)
      conn             = ridley_connection(options)

      cached_cookbooks.each do |cookbook|
        Berkshelf.formatter.upload(cookbook.cookbook_name, cookbook.version, conn.server_url)
        validate_files!(cookbook)

        begin
          conn.cookbook.upload(cookbook.path, upload_opts.merge(name: cookbook.cookbook_name))
        rescue Ridley::Errors::FrozenCookbook => ex
          if options[:halt_on_frozen]
            raise Berkshelf::FrozenCookbook, ex
          end
        end
      end

      if options[:skip_dependencies]
        missing_cookbooks = options.fetch(:cookbooks, nil) - cached_cookbooks.map(&:cookbook_name)
        unless missing_cookbooks.empty?
          msg = "Unable to upload cookbooks: #{missing_cookbooks.sort.join(', ')}\n"
          msg << "Specified cookbooks must be defined within the Berkshelf file when using the"
          msg << " `--skip-dependencies` option"
          raise ExplicitCookbookNotFound.new(msg)
        end
      end
    rescue Ridley::Errors::RidleyError => ex
      log_exception(ex)
      raise ChefConnectionError, ex # todo implement
    ensure
      conn.terminate if conn && conn.alive?
    end

    # Resolve this Berksfile and apply the locks found in the generated Berksfile.lock to the
    # target Chef environment
    #
    # @param [String] environment_name
    #
    # @option options [Hash] :ssl_verify (true)
    #   Disable/Enable SSL verification during uploads
    #
    # @raise [EnvironmentNotFound] if the target environment was not found
    # @raise [ChefConnectionError] if you are locking cookbooks with an invalid or not-specified client configuration
    def apply(environment_name, options = {})
      conn        = ridley_connection(options)
      environment = conn.environment.find(environment_name)

      if environment
        install

        environment.cookbook_versions = {}.tap do |cookbook_versions|
          lockfile.sources.each { |source| cookbook_versions[source.name] = "= #{source.locked_version.to_s}" }
        end

        environment.save
      else
        raise EnvironmentNotFound.new(environment_name)
      end
    rescue Ridley::Errors::RidleyError => ex
      raise ChefConnectionError, ex
    ensure
      conn.terminate if conn && conn.alive?
    end

    # Package the given cookbook for distribution outside of berkshelf. If the
    # name attribute is not given, all cookbooks in the Berksfile will be
    # packaged.
    #
    # @param [String] name
    #   the name of the cookbook to package
    # @param [Hash] options
    #   a list of options
    #
    # @option options [String] :output
    #   the path to output the tarball
    # @option options [Boolean] :skip_dependencies
    #   package cookbook dependencies as well
    # @option options [Boolean] :ignore_chefignore
    #   do not apply the chefignore file to the packed cookbooks
    #
    # @return [String]
    #   the path to the package
    def package(name = nil, options = {})
      tar_name = "#{name || 'package'}.tar.gz"
      output = File.expand_path(File.join(options[:output], tar_name))

      unless name.nil?
        source = self.find(name)
        raise CookbookNotFound, "Cookbook '#{name}' is not in your Berksfile" unless source

        package = Berkshelf.ui.mute {
          self.resolve(source, options)[:solution]
        }
      else
        package = Berkshelf.ui.mute {
          self.resolve(sources, options)[:solution]
        }
      end

      package.each do |cookbook|
        validate_files!(cookbook)
      end

      Dir.mktmpdir do |tmp|
        package.each do |cached_cookbook|
          path = cached_cookbook.path.to_s
          destination = File.join(tmp, cached_cookbook.cookbook_name)

          FileUtils.cp_r(path, destination)

          unless options[:ignore_chefignore]
            if ignore_file = Berkshelf::Chef::Cookbook::Chefignore.find_relative_to(path)
              chefignore = Berkshelf::Chef::Cookbook::Chefignore.new(ignore_file)
              chefignore.remove_ignores_from(destination) if chefignore
            end
          end
        end

        FileUtils.mkdir_p(options[:output])

        Dir.chdir(tmp) do |dir|
          tgz = Zlib::GzipWriter.new(File.open(output, 'wb'))
          Archive::Tar::Minitar.pack('.', tgz)
        end
      end

      Berkshelf.formatter.package(name, output)

      output
    end

    # Finds a solution for the Berksfile and returns an array of CachedCookbooks.
    #
    # @param [Array<Berkshelf::CookbookSource>] sources
    #   Array of cookbook sources to resolve
    #
    # @option options [Boolean] :skip_dependencies
    #   Skip resolving of dependencies
    #
    # @return [Array<Berkshelf::CachedCookbooks>]
    def resolve(sources = [], options = {})
      resolver = Resolver.new(
        self,
        sources: sources,
        skip_dependencies: options[:skip_dependencies]
      )

      { solution: resolver.resolve, sources: resolver.sources }
    end

    # Get the lockfile corresponding to this Berksfile. This is necessary because
    # the user can specify a different path to the Berksfile. So assuming the lockfile
    # is named "Berksfile.lock" is a poor assumption.
    #
    # @return [Berkshelf::Lockfile]
    #   the lockfile corresponding to this berksfile, or a new Lockfile if one does
    #   not exist
    def lockfile
      @lockfile ||= Berkshelf::Lockfile.new(self)
    end

    private

      def ridley_connection(options = {})
        ridley_options               = options.slice(:ssl)
        ridley_options[:server_url]  = options[:server_url] || Berkshelf::Config.instance.chef.chef_server_url
        ridley_options[:client_name] = options[:client_name] || Berkshelf::Config.instance.chef.node_name
        ridley_options[:client_key]  = options[:client_key] || Berkshelf::Config.instance.chef.client_key
        ridley_options[:ssl]         = { verify: (options[:ssl_verify] || Berkshelf::Config.instance.ssl.verify) }

        unless ridley_options[:server_url].present?
          raise ChefConnectionError, 'Missing required attribute in your Berkshelf configuration: chef.server_url'
        end

        unless ridley_options[:client_name].present?
          raise ChefConnectionError, 'Missing required attribute in your Berkshelf configuration: chef.node_name'
        end

        unless ridley_options[:client_key].present?
          raise ChefConnectionError, 'Missing required attribute in your Berkshelf configuration: chef.client_key'
        end

        Ridley.new(ridley_options)
      end

      def descendant_directory?(candidate, parent)
        hack = FileUtils::Entry_.new('/tmp')
        hack.send(:descendant_diretory?, candidate, parent)
      end

      # Determine if any cookbooks were specified that aren't in our shelf.
      #
      # @option options [Array<String>] :cookbooks
      #   a list of strings of cookbook names
      #
      # @raise [Berkshelf::CookbookNotFound]
      #   if a cookbook name is given that does not exist
      def validate_cookbook_names!(options = {})
        missing = (Array(options[:cookbooks]) - sources.map(&:name))
        unless missing.empty?
          raise Berkshelf::CookbookNotFound,
            "Could not find cookbooks #{missing.collect{ |c| "'#{c}'" }.join(', ')} " +
            "in any of the sources. #{missing.size == 1 ? 'Is it' : 'Are they' } in your Berksfile?"
        end
      end

      # The list of sources "locked" by the lockfile.
      #
      # @return [Array<Berkshelf::CookbookSource>]
      #   the list of sources in this lockfile
      def locked_sources
        lockfile.sources
      end

      # Merge the locked sources against the given sources.
      #
      # For each the given sources, check if there's a locked version that
      # still satisfies the version constraint. If it does, "lock" that source
      # because we should just use the locked version.
      #
      # If a locked source exists, but doesn't satisfy the constraint, raise a
      # {Berkshelf::OutdatedCookbookSource} and tell the user to run update.
      def apply_lockfile(sources = [])
        sources.collect do |source|
          source_from_lockfile(source) || source
        end
      end

      def source_from_lockfile(source)
        locked_source = lockfile.find(source)

        return nil unless locked_source

        # If there's a locked_version, make sure it's still satisfied
        # by the constraint
        if locked_source.locked_version
          unless source.version_constraint.satisfies?(locked_source.locked_version)
            raise Berkshelf::OutdatedCookbookSource.new(locked_source, source)
          end
        end

        # Update to the new constraint (it might have changed, but still be satisfied)
        locked_source.version_constraint = source.version_constraint
        locked_source
      end

      # Validate that the given cookbook does not have "bad" files. Currently
      # this means including spaces in filenames (such as recipes)
      #
      # @param [Berkshelf::CachedCookbook] cookbook
      #  the Cookbook to validate
      def validate_files!(cookbook)
        path = cookbook.path.to_s

        files = Dir.glob(File.join(path, '**', '*.rb')).select do |f|
          parent = Pathname.new(path).dirname.to_s
          f.gsub(parent, '') =~ /[[:space:]]/
        end

        raise Berkshelf::InvalidCookbookFiles.new(cookbook, files) unless files.empty?
      end

      # Verify that the licenses of all the cached cookbooks fall in the realm of
      # allowed licenses from the Berkshelf Config.
      #
      # @raise [Berkshelf::LicenseNotAllowed]
      #   if the license is not permitted and `raise_license_exception` is true
      def verify_licenses!
        licenses = Array(Berkshelf::Config.instance.allowed_licenses)
        return if licenses.empty?

        sources.each do |source|
          next if source.location.is_a?(Berkshelf::PathLocation)
          cached = source.cached_cookbook

          begin
            unless licenses.include?(cached.metadata.license)
              raise Berkshelf::LicenseNotAllowed.new(cached)
            end
          rescue Berkshelf::LicenseNotAllowed => e
            if Berkshelf::Config.instance.raise_license_exception
              FileUtils.rm_rf(cached.path)
              raise
            end

            Berkshelf.ui.warn(e.to_s)
          end
        end
      end

  end
end
