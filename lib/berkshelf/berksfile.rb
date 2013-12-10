require_relative "packager"

module Berkshelf
  class Berksfile
    class << self
      # The sources to use if no sources are explicitly provided
      #
      # @return [Array<Berkshelf::Source>]
      def default_sources
        @default_sources ||= [ Source.new(DEFAULT_API_URL) ]
      end

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
    end

    DEFAULT_API_URL = "https://api.berkshelf.com".freeze

    include Berkshelf::Mixin::Logging
    include Berkshelf::Mixin::DSLEval
    extend Forwardable

    expose_method :source
    expose_method :site     # @todo remove in Berkshelf 4.0
    expose_method :chef_api # @todo remove in Berkshelf 4.0
    expose_method :metadata
    expose_method :cookbook
    expose_method :group

    @@active_group = nil

    # @return [String]
    #   The path on disk to the file representing this instance of Berksfile
    attr_reader :filepath

    # @param [String] path
    #   path on disk to the file containing the contents of this Berksfile
    def initialize(path)
      @filepath         = path
      @dependencies     = Hash.new
      @sources          = Array.new
    end

    # Add a cookbook dependency to the Berksfile to be retrieved and have its dependencies recursively retrieved
    # and resolved.
    #
    # @example a cookbook dependency that will be retrieved from one of the default locations
    #   cookbook 'artifact'
    #
    # @example a cookbook dependency that will be retrieved from a path on disk
    #   cookbook 'artifact', path: '/Users/reset/code/artifact'
    #
    # @example a cookbook dependency that will be retrieved from a Git server
    #   cookbook 'artifact', git: 'git://github.com/RiotGames/artifact-cookbook.git'
    #
    # @overload cookbook(name, version_constraint, options = {})
    #   @param [#to_s] name
    #   @param [#to_s] version_constraint
    #
    #   @option options [Symbol, Array] :group
    #     the group or groups that the cookbook belongs to
    #   @option options [String] :path
    #     a filepath to the cookbook on your local disk
    #   @option options [String] :git
    #     the Git URL to clone
    #
    #   @see PathLocation
    #   @see GitLocation
    # @overload cookbook(name, options = {})
    #   @param [#to_s] name
    #
    #   @option options [Symbol, Array] :group
    #     the group or groups that the cookbook belongs to
    #   @option options [String] :path
    #     a filepath to the cookbook on your local disk
    #   @option options [String] :git
    #     the Git URL to clone
    #
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

      add_dependency(name, constraint, options)
    end

    def group(*args)
      @@active_group = args
      yield
      @@active_group = nil
    end

    # Use a Cookbook metadata file to determine additional cookbook dependencies to retrieve. All
    # dependencies found in the metadata will use the default locations set in the Berksfile (if any are set)
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

      add_dependency(name, nil, path: path, metadata: true)
    end

    # Add a Berkshelf API source to use when building the index of known cookbooks. The indexes will be
    # searched in the order they are added. If a cookbook is found in the first source then a cookbook
    # in a second source would not be used.
    #
    # @example
    #   source "https://api.berkshelf.com"
    #   source "https://berks-api.riotgames.com"
    #
    # @param [String] api_url
    #   url for the api to add
    #
    # @raise [Berkshelf::InvalidSourceURI]
    #
    # @return [Array<Berkshelf::Source>]
    def source(api_url)
      new_source = Source.new(api_url)
      @sources.push(new_source) unless @sources.include?(new_source)
    end

    # @return [Array<Berkshelf::Source>]
    def sources
      @sources.empty? ? self.class.default_sources : @sources
    end

    # @todo remove in Berkshelf 4.0
    #
    # @raise [Berkshelf::DeprecatedError]
    def site(*args)
      if args.first == :opscode
        Berkshelf.formatter.deprecation "Your Berksfile contains a site location pointing to the Opscode Community " +
          "Site (site :opscode). Site locations have been replaced by the source location. Change this to: " +
          "'source \"http://api.berkshelf.com\"' to remove this warning. For more information visit " +
          "https://github.com/berkshelf/berkshelf/wiki/deprecated-locations"
        source(DEFAULT_API_URL)
        return
      end

      raise Berkshelf::DeprecatedError.new "Your Berksfile contains a site location. Site locations have been " +
        " replaced by the source location. Please remove your site location and try again. For more information " +
        " visit https://github.com/berkshelf/berkshelf/wiki/deprecated-locations"
    end

    # @todo remove in Berkshelf 4.0
    #
    # @raise [Berkshelf::DeprecatedError]
    def chef_api(*args)
      raise Berkshelf::DeprecatedError.new "Your Berksfile contains a chef_api location. Chef API locations have " +
        " been replaced by the source location. Please remove your site location and try again. For more " +
        " information visit https://github.com/berkshelf/berkshelf/wiki/deprecated-locations"
    end

    # Add a dependency of the given name and constraint to the array of dependencies.
    #
    # @param [String] name
    #   the name of the dependency to add
    # @param [String, Solve::Constraint] constraint
    #   the constraint to lock the dependency to
    #
    # @option options [Symbol, Array] :group
    #   the group or groups that the cookbook belongs to
    # @option options [String] :path
    #   a filepath to the cookbook on your local disk
    # @option options [String] :git
    #   the Git URL to clone
    #
    # @raise [DuplicateDependencyDefined] if a dependency is added whose name conflicts
    #   with a dependency who has already been added.
    #
    # @return [Array<Berkshelf::Dependency]
    def add_dependency(name, constraint = nil, options = {})
      if has_dependency?(name)
        # Only raise an exception if the dependency is a true duplicate
        groups = (options[:group].nil? || options[:group].empty?) ? [:default] : options[:group]
        if !(@dependencies[name].groups & groups).empty?
          raise DuplicateDependencyDefined,
            "Berksfile contains multiple entries named '#{name}'. Use only one, or put them in different groups."
        end
      end

      if options[:path]
        metadata_file = File.join(options[:path], 'metadata.rb')
      end

      options[:constraint] = constraint

      @dependencies[name] = Berkshelf::Dependency.new(self, name, options)
    end

    # @param [#to_s] dependency
    #   the dependency to remove
    #
    # @return [Berkshelf::Dependency]
    def remove_dependency(dependency)
      @dependencies.delete(dependency.to_s)
    end

    # @param [#to_s] dependency
    #   the dependency to check presence of
    #
    # @return [Boolean]
    def has_dependency?(dependency)
      @dependencies.has_key?(dependency.to_s)
    end

    # @option options [Symbol, Array] :except
    #   Group(s) to exclude which will cause any dependencies marked as a member of the
    #   group to not be installed
    # @option options [Symbol, Array] :only
    #   Group(s) to include which will cause any dependencies marked as a member of the
    #   group to be installed and all others to be ignored
    # @option cookbooks [String, Array] :cookbooks
    #   Names of the cookbooks to retrieve dependencies for
    #
    # @return [Array<Berkshelf::Dependency>]
    def dependencies(options = {})
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
        @dependencies.values.select { |dependency| cookbooks.include?(dependency.name) }
      when !except.empty?
        @dependencies.values.select { |dependency| (except & dependency.groups).empty? }
      when !only.empty?
        @dependencies.values.select { |dependency| !(only & dependency.groups).empty? }
      else
        @dependencies.values
      end
    end

    #
    # Behaves the same as {Berksfile#dependencies}, but this method returns an
    # array of CachedCookbook objects instead of dependency objects. This method
    # relies on the {Berksfile#retrieve_locked} method to load the proper
    # cached cookbook from the Berksfile + lockfile combination.
    #
    # @see [Berksfile#dependencies]
    #   for a description of the +options+ hash
    # @see [Berksfile#retrieve_locked]
    #   for a list of possible exceptions that might be raised and why
    #
    # @return [Array<CachedCookbook>]
    #
    def cookbooks(options = {})
      dependencies(options).map { |dependency| retrieve_locked(dependency) }
    end

    # Find a dependency defined in this berksfile by name.
    #
    # @param [String] name
    #   the name of the cookbook dependency to search for
    # @return [Berkshelf::Dependency, nil]
    #   the cookbook dependency, or nil if one does not exist
    def find(name)
      @dependencies[name]
    end

    # Find a dependency, raising an exception if it is not found.
    # @see {find}
    def find!(name)
      find(name) || raise(DependencyNotFound.new(name))
    end

    # @return [Hash]
    #   a hash containing group names as keys and an array of Berkshelf::Dependencies
    #   that are a member of that group as values
    #
    #   Example:
    #     {
    #       nautilus: [
    #         #<Berkshelf::Dependency: nginx (~> 1.0.0)>,
    #         #<Berkshelf::Dependency: mysql (~> 1.2.4)>
    #       ],
    #       skarner: [
    #         #<Berkshelf::Dependency: nginx (~> 1.0.0)>
    #       ]
    #     }
    def groups
      {}.tap do |groups|
        dependencies.each do |dependency|
          dependency.groups.each do |group|
            groups[group] ||= []
            groups[group] << dependency
          end
        end
      end
    end

    # @param [String] name
    #   name of the dependency to return
    #
    # @return [Berkshelf::Dependency]
    def [](name)
      @dependencies[name]
    end
    alias_method :get_dependency, :[]

    # Install the dependencies listed in the Berksfile, respecting the locked
    # versions in the Berksfile.lock.
    #
    # 1. Check that a lockfile exists. If a lockfile does not exist, all
    #    dependencies are considered to be "unlocked". If a lockfile is specified, a
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
    # 2. Resolve the collection of locked and unlocked dependencies.
    #
    # 3. Write out a new lockfile.
    #
    # @option options [Symbol, Array] :except
    #   Group(s) to exclude which will cause any dependencies marked as a member of the
    #   group to not be installed
    # @option options [Symbol, Array] :only
    #   Group(s) to include which will cause any dependencies marked as a member of the
    #   group to be installed and all others to be ignored
    # @option cookbooks [String, Array] :cookbooks
    #   Names of the cookbooks to retrieve dependencies for
    #
    # @raise [Berkshelf::OutdatedDependency]
    #   if the lockfile constraints do not satisfy the Berksfile constraints
    #
    # @return [Array<Berkshelf::CachedCookbook>]
    def install(options = {})
      Installer.new(self).run(options)
    end

    # @option options [Symbol, Array] :except
    #   Group(s) to exclude which will cause any dependencies marked as a member of the
    #   group to not be installed
    # @option options [Symbol, Array] :only
    #   Group(s) to include which will cause any dependencies marked as a member of the
    #   group to be installed and all others to be ignored
    # @option cookbooks [String, Array] :cookbooks
    #   Names of the cookbooks to retrieve dependencies for
    def update(options = {})
      validate_cookbook_names!(options)

      # Unlock any/all specified cookbooks
      dependencies(options).each { |dependency| lockfile.unlock(dependency) }

      # NOTE: We intentionally do NOT pass options to the installer
      self.install
    end

    # Retrieve information about a given cookbook that is installed by this Berksfile.
    # Unlike {#find}, which returns a dependency, this method returns the corresponding
    # CachedCookbook for the given name.
    #
    # @raise [LockfileNotFound]
    #   if there is no lockfile containing that cookbook
    # @raise [CookbookNotFound]
    #   if there is a lockfile with a cookbook, but the cookbook is not downloaded
    #
    # @param [Dependency] name
    #   the name of the cookbook to find
    #
    # @return [CachedCookbook]
    #   the CachedCookbook that corresponds to the given name parameter
    def retrieve_locked(dependency)
      lockfile.retrieve(dependency)
    end

    # The cached cookbooks installed by this Berksfile.
    #
    # @raise [Berkshelf::LockfileNotFound]
    #   if there is no lockfile
    # @raise [Berkshelf::CookbookNotFound]
    #   if a listed source could not be found
    #
    # @return [Hash<Berkshelf::Dependency, Berkshelf::CachedCookbook>]
    #   the list of dependencies as keys and the cached cookbook as the value
    def list
      Hash[*dependencies.sort.collect { |dependency| [dependency, retrieve_locked(dependency)] }.flatten]
    end

    # List of all the cookbooks which have a newer version found at a source that satisfies
    # the constraints of your dependencies
    #
    # @option options [Symbol, Array] :except
    #   Group(s) to exclude which will cause any dependencies marked as a member of the
    #   group to not be installed
    # @option options [Symbol, Array] :only
    #   Group(s) to include which will cause any dependencies marked as a member of the
    #   group to be installed and all others to be ignored
    # @option cookbooks [String, Array] :cookbooks
    #   Whitelist of cookbooks to to check for updated versions for
    #
    # @return [Hash]
    #   a hash of cached cookbooks and their latest version. An empty hash is returned
    #   if there are no newer cookbooks for any of your dependencies
    #
    # @example
    #   berksfile.outdated #=> {
    #     #<CachedCookbook name="artifact"> => "0.11.2"
    #   }
    def outdated(options = {})
      validate_cookbook_names!(options)

      outdated = {}
      dependencies(options).each do |dependency|
        locked = retrieve_locked(dependency)
        outdated[dependency.name] = {}

        sources.each do |source|
          cookbooks = source.versions(dependency.name)

          latest = cookbooks.select do |cookbook|
            dependency.version_constraint.satisfies?(cookbook.version) &&
            cookbook.version != locked.version
          end.sort_by { |cookbook| cookbook.version }.last

          unless latest.nil?
            outdated[dependency.name][source.uri.to_s] = latest
          end
        end
      end

      outdated.reject { |name, newer| newer.empty? }
    end

    # Upload the cookbooks installed by this Berksfile
    #
    # @option options [Boolean] :force (false)
    #   Upload the Cookbook even if the version already exists and is frozen on the
    #   target Chef Server
    # @option options [Boolean] :freeze (true)
    #   Freeze the uploaded Cookbook on the Chef Server so that it cannot be overwritten
    # @option options [Symbol, Array] :except
    #   Group(s) to exclude which will cause any dependencies marked as a member of the
    #   group to not be installed
    # @option options [Symbol, Array] :only
    #   Group(s) to include which will cause any dependencies marked as a member of the
    #   group to be installed and all others to be ignored
    # @option options [String, Array] :cookbooks
    #   Names of the cookbooks to retrieve dependencies for
    # @option options [Hash] :ssl_verify (true)
    #   Disable/Enable SSL verification during uploads
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
    # @raise [Berkshelf::UploadFailure]
    #   if you are uploading cookbooks with an invalid or not-specified client key
    # @raise [Berkshelf::DependencyNotFound]
    #   if one of the given cookbooks is not a dependency defined in the Berksfile
    # @raise [Berkshelf::FrozenCookbook]
    #   if the cookbook being uploaded is a {metadata} cookbook and is already
    #   frozen on the remote Chef Server; indirect dependencies or non-metadata
    #   dependencies are just skipped
    def upload(options = {})
      options = {
        force: false,
        freeze: true,
        halt_on_frozen: false,
        cookbooks: [],
        validate: true
      }.merge(options)

      validate_cookbook_names!(options)

      cached_cookbooks = install(options)
      cached_cookbooks = filter_to_upload(cached_cookbooks, options[:cookbooks]) if options[:cookbooks]
      do_upload(cached_cookbooks, options)
    end

    # Package the given cookbook for distribution outside of berkshelf. If the
    # name attribute is not given, all cookbooks in the Berksfile will be
    # packaged.
    #
    # @param [String] path
    #   the path where the tarball will be created
    #
    # @option options [Symbol, Array] :except
    #   Group(s) to exclude which will cause any dependencies marked as a member of the
    #   group to not be installed
    # @option options [Symbol, Array] :only
    #   Group(s) to include which will cause any dependencies marked as a member of the
    #   group to be installed and all others to be ignored
    #
    # @raise [Berkshelf::PackageError]
    #
    # @return [String]
    #   the path to the package
    def package(path, options = {})
      packager = Packager.new(path)
      packager.validate!

      outdir = Dir.mktmpdir do |temp_dir|
        source = Berkshelf.ui.mute do
          vendor(File.join(temp_dir, "cookbooks"), options.slice(:only, :except))
        end
        packager.run(source)
      end

      Berkshelf.formatter.package(outdir)
      outdir
    end

    # Install the Berksfile or Berksfile.lock and then copy the cached cookbooks into
    # directories within the given destination matching their name.
    #
    # @param [String] destination
    #   filepath to vendor cookbooks to
    #
    # @option options [Symbol, Array] :except
    #   Group(s) to exclude which will cause any dependencies marked as a member of the
    #   group to not be installed
    # @option options [Symbol, Array] :only
    #   Group(s) to include which will cause any dependencies marked as a member of the
    #   group to be installed and all others to be ignored
    #
    # @return [String, nil]
    #   the expanded path cookbooks were vendored to or nil if nothing was vendored
    def vendor(destination, options = {})
      destination = File.expand_path(destination)

      if Dir.exist?(destination)
        raise VendorError, "destination already exists #{destination}. Delete it and try again or use a " +
          "different filepath."
      end

      scratch          = Berkshelf.mktmpdir
      chefignore       = nil
      cached_cookbooks = install(options.slice(:except, :only))

      return nil if cached_cookbooks.empty?

      cached_cookbooks.each do |cookbook|
        Berkshelf.formatter.vendor(cookbook, destination)
        cookbook_destination = File.join(scratch, cookbook.cookbook_name, '/')
        FileUtils.mkdir_p(cookbook_destination)

        # Dir.glob does not support backslash as a File separator
        src   = cookbook.path.to_s.gsub('\\', '/')
        files = Dir.glob(File.join(src, '*'))

        chefignore = Ridley::Chef::Chefignore.new(cookbook.path.to_s) rescue nil
        chefignore.apply!(files) if chefignore

        unless cookbook.compiled_metadata?
          cookbook.compile_metadata(cookbook_destination)
        end

        # Don't vendor the raw metadata (metadata.rb). The raw metadata is unecessary for the
        # client, and this is required until compiled metadata (metadata.json) takes precedence over
        # raw metadata in the Chef-Client.
        #
        # We can change back to including the raw metadata in the future after this has been fixed or
        # just remove these comments. There is no circumstance that I can currently think of where
        # raw metadata should ever be read by the client.
        #
        # - Jamie
        #
        # See the following tickets for more information:
        #   * https://tickets.opscode.com/browse/CHEF-4811
        #   * https://tickets.opscode.com/browse/CHEF-4810
        files.reject! { |file| File.basename(file) == "metadata.rb" }

        FileUtils.cp_r(files, cookbook_destination)
      end

      FileUtils.cp(lockfile.filepath, File.join(scratch, Lockfile::DEFAULT_FILENAME))

      FileUtils.mv(scratch, destination)
      destination
    end

    # Get the lockfile corresponding to this Berksfile. This is necessary because
    # the user can specify a different path to the Berksfile. So assuming the lockfile
    # is named "Berksfile.lock" is a poor assumption.
    #
    # @return [Berkshelf::Lockfile]
    #   the lockfile corresponding to this berksfile, or a new Lockfile if one does
    #   not exist
    def lockfile
      @lockfile ||= Lockfile.from_berksfile(self)
    end

    private

      def do_upload(cookbooks, options = {})
        @skipped = []

        Berkshelf.ridley_connection(options) do |conn|
          cookbooks.each do |cookbook|
            Berkshelf.formatter.upload(cookbook, conn)
            validate_files!(cookbook)

            begin
              conn.cookbook.upload(cookbook.path, {
                force: options[:force],
                freeze: options[:freeze],
                name: cookbook.cookbook_name,
                validate: options[:validate]
              })
            rescue Ridley::Errors::FrozenCookbook => ex
              if options[:halt_on_frozen]
                raise Berkshelf::FrozenCookbook.new(cookbook)
              end

              Berkshelf.formatter.skip(cookbook, conn)
              @skipped << cookbook
            end
          end
        end

        unless @skipped.empty?
          Berkshelf.formatter.msg "Skipped uploading some cookbooks because they" <<
            " already exist on the remote server and are frozen. Re-run with the `--force`" <<
            " flag to force overwrite these cookbooks:" <<
            "\n\n" <<
            "  * " << @skipped.map { |c| "#{c.cookbook_name} (#{c.version})" }.join("\n  * ")
        end
      end

      # Filter the cookbooks to upload based on a set of given names. The dependencies of a cookbook
      # will always be included in the filtered results even if the dependency's name is not
      # explicitly provided.
      #
      # @param [Array<Berkshelf::CachedCookbooks>] cookbooks
      #   set of cookbooks to filter
      # @param [Array<String>] names
      #   names of cookbooks to include in the filtered results
      #
      # @return [Array<Berkshelf::CachedCookbooks]
      def filter_to_upload(cookbooks, names)
        unless names.empty?
          explicit = cookbooks.select { |cookbook| names.include?(cookbook.cookbook_name) }
          explicit.each do |cookbook|
            cookbook.dependencies.each do |name, version|
              explicit += cookbooks.select { |cookbook| cookbook.cookbook_name == name }
            end
          end
          cookbooks = explicit.uniq
        end
        cookbooks
      end

      # Determine if any cookbooks were specified that aren't in our shelf.
      #
      # @option options [Array<String>] :cookbooks
      #   a list of strings of cookbook names
      #
      # @raise [Berkshelf::DependencyNotFound]
      #   if a cookbook name is given that does not exist
      def validate_cookbook_names!(options = {})
        missing = (Array(options[:cookbooks]) - dependencies.map(&:name))

        unless missing.empty?
          raise Berkshelf::DependencyNotFound.new(missing)
        end
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
  end
end
