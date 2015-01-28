require_relative "packager"

module Berkshelf
  class Berksfile
    class << self
      # Instantiate a Berksfile from the given options. This method is used
      # heavily by the CLI to reduce duplication.
      #
      # @param (see Berksfile#initialize)
      def from_options(options = {})
        options[:berksfile] ||= File.join(Dir.pwd, Berkshelf::DEFAULT_FILENAME)
        from_file(options[:berksfile], options.slice(:except, :only))
      end

      # @param [#to_s] file
      #   a path on disk to a Berksfile to instantiate from
      #
      # @return [Berksfile]
      def from_file(file, options = {})
        raise BerksfileNotFound.new(file) unless File.exist?(file)

        begin
          new(file, options).evaluate_file(file)
        rescue => ex
          raise BerksfileReadError.new(ex)
        end
      end
    end

    DEFAULT_API_URL = "https://supermarket.chef.io".freeze

    # Don't vendor VCS files.
    # Reference GNU tar --exclude-vcs: https://www.gnu.org/software/tar/manual/html_section/tar_49.html
    EXCLUDED_VCS_FILES_WHEN_VENDORING = ['.arch-ids', '{arch}', '.bzr', '.bzrignore', '.bzrtags', 'CVS', '.cvsignore', '_darcs', '.git', '.hg', '.hgignore', '.hgrags', 'RCS', 'SCCS', '.svn', '**/.git'].freeze

    include Mixin::Logging
    include Cleanroom
    extend Forwardable

    # @return [String]
    #   The path on disk to the file representing this instance of Berksfile
    attr_reader :filepath

    # Create a new Berksfile object.
    #
    # @param [String] path
    #   path on disk to the file containing the contents of this Berksfile
    #
    # @option options [Symbol, Array<String>] :except
    #   Group(s) to exclude which will cause any dependencies marked as a member of the
    #   group to not be installed
    # @option options [Symbol, Array<String>] :only
    #   Group(s) to include which will cause any dependencies marked as a member of the
    #   group to be installed and all others to be ignored
    def initialize(path, options = {})
      @filepath         = File.expand_path(path)
      @dependencies     = Hash.new
      @sources          = Hash.new

      if options[:except] && options[:only]
        raise ArgumentError, 'Cannot specify both :except and :only!'
      elsif options[:except]
        except = Array(options[:except]).collect(&:to_sym)
        @filter = ->(dependency) { (except & dependency.groups).empty? }
      elsif options[:only]
        only = Array(options[:only]).collect(&:to_sym)
        @filter = ->(dependency) { !(only & dependency.groups).empty? }
      else
        @filter = ->(dependency) { true }
      end
    end

    # Activate a Berkshelf extension at runtime.
    #
    # @example Activate the Mercurial extension
    #   extension 'hg'
    #
    # @raise [LoadError]
    #   if the extension cannot be loaded
    #
    # @param [String] name
    #   the name of the extension to activate
    #
    # @return [true]
    def extension(name)
      require "berkshelf/#{name}"
      true
    rescue LoadError
      raise LoadError, "Could not load an extension by the name `#{name}'. " \
        "Please make sure it is installed."
    end
    expose :extension

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

      if @active_group
        options[:group] += @active_group
      end

      add_dependency(name, constraint, options)
    end
    expose :cookbook

    def group(*args)
      @active_group = args
      yield
      @active_group = nil
    end
    expose :group

    # Use a Cookbook metadata file to determine additional cookbook dependencies to retrieve. All
    # dependencies found in the metadata will use the default locations set in the Berksfile (if any are set)
    # or the default locations defined by Berkshelf.
    #
    # @param [Hash] options
    #
    # @option options [String] :path
    #   path to the metadata file
    def metadata(options = {})
      path          = options[:path] || File.dirname(filepath)
      metadata_path = File.expand_path(File.join(path, 'metadata.rb'))
      metadata      = Ridley::Chef::Cookbook::Metadata.from_file(metadata_path)

      add_dependency(metadata.name, nil, path: path, metadata: true)
    end
    expose :metadata

    # Add a Berkshelf API source to use when building the index of known cookbooks. The indexes will be
    # searched in the order they are added. If a cookbook is found in the first source then a cookbook
    # in a second source would not be used.
    #
    # @example
    #   source "https://supermarket.chef.io"
    #   source "https://berks-api.riotgames.com"
    #
    # @param [String] api_url
    #   url for the api to add
    #
    # @raise [InvalidSourceURI]
    #
    # @return [Array<Source>]
    def source(api_url)
      @sources[api_url] = Source.new(api_url)
    end
    expose :source

    # @return [Array<Source>]
    def sources
      if @sources.empty?
        raise NoAPISourcesDefined
      else
        @sources.values
      end
    end

    # @param [Dependency] dependency
    #   the dependency to find the source for
    def source_for(name, version)
      sources.find { |source| source.cookbook(name, version) }
    end

    # @todo remove in Berkshelf 4.0
    #
    # @raise [DeprecatedError]
    def site(*args)
      if args.first == :opscode
        Berkshelf.formatter.deprecation "Your Berksfile contains a site location pointing to the Opscode Community " +
          "Site (site :opscode). Site locations have been replaced by the source location. Change this to: " +
          "'source \"https://supermarket.chef.io\"' to remove this warning. For more information visit " +
          "https://github.com/berkshelf/berkshelf/wiki/deprecated-locations"
        source(DEFAULT_API_URL)
        return
      end

      raise DeprecatedError.new "Your Berksfile contains a site location. Site locations have been " +
        " replaced by the source location. Please remove your site location and try again. For more information " +
        " visit https://github.com/berkshelf/berkshelf/wiki/deprecated-locations"
    end
    expose :site

    # @todo remove in Berkshelf 4.0
    #
    # @raise [DeprecatedError]
    def chef_api(*args)
      raise DeprecatedError.new "Your Berksfile contains a chef_api location. Chef API locations have " +
        " been replaced by the source location. Please remove your site location and try again. For more " +
        " information visit https://github.com/berkshelf/berkshelf/wiki/deprecated-locations"
    end
    expose :chef_api

    # Add a dependency of the given name and constraint to the array of dependencies.
    #
    # @param [String] name
    #   the name of the dependency to add
    # @param [String, Semverse::Constraint] constraint
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
    # @return [Array<Dependency]
    def add_dependency(name, constraint = nil, options = {})
      if @dependencies[name]
        # Only raise an exception if the dependency is a true duplicate
        groups = (options[:group].nil? || options[:group].empty?) ? [:default] : options[:group]
        if !(@dependencies[name].groups & groups).empty?
          raise DuplicateDependencyDefined.new(name)
        end
      end

      if options[:path]
        metadata_file = File.join(options[:path], 'metadata.rb')
      end

      options[:constraint] = constraint

      @dependencies[name] = Dependency.new(self, name, options)
    end

    # Check if the Berksfile has the given dependency, taking into account
    # +group+ and --only/--except flags.
    #
    # @param [String, Dependency] dependency
    #   the dependency or name of dependency to check presence of
    #
    # @return [Boolean]
    def has_dependency?(dependency)
      name = Dependency.name(dependency)
      dependencies.map(&:name).include?(name)
    end

    # @return [Array<Dependency>]
    def dependencies
      @dependencies.values.sort.select(&@filter)
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
    def cookbooks
      dependencies.map { |dependency| retrieve_locked(dependency) }
    end

    # Find a dependency defined in this berksfile by name.
    #
    # @param [String] name
    #   the name of the cookbook dependency to search for
    # @return [Dependency, nil]
    #   the cookbook dependency, or nil if one does not exist
    def find(name)
      @dependencies[name]
    end

    # @return [Hash]
    #   a hash containing group names as keys and an array of Dependencies
    #   that are a member of that group as values
    #
    #   Example:
    #     {
    #       nautilus: [
    #         #<Dependency: nginx (~> 1.0.0)>,
    #         #<Dependency: mysql (~> 1.2.4)>
    #       ],
    #       skarner: [
    #         #<Dependency: nginx (~> 1.0.0)>
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
    # @return [Dependency]
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
    #      this method will raise a {OutdatedCookbookSource}, and
    #      inform the user to run <tt>berks update COOKBOOK</tt> to remedy the issue.
    #    - Remove any locked sources that no longer exist in the Berksfile
    #      (i.e. a cookbook source was removed from the Berksfile).
    #
    # 2. Resolve the collection of locked and unlocked dependencies.
    #
    # 3. Write out a new lockfile.
    #
    # @raise [OutdatedDependency]
    #   if the lockfile constraints do not satisfy the Berksfile constraints
    #
    # @return [Array<CachedCookbook>]
    def install
      Installer.new(self).run
    end

    # Update the given set of dependencies (or all if no names are given).
    #
    # @option options [String, Array<String>] :cookbooks
    #   Names of the cookbooks to retrieve dependencies for
    def update(*names)
      validate_lockfile_present!
      validate_cookbook_names!(names)

      Berkshelf.log.info "Updating cookbooks"

      # Calculate the list of cookbooks to unlock
      if names.empty?
        Berkshelf.log.debug "  Unlocking all the things!"
        lockfile.unlock_all
      else
        names.each do |name|
          Berkshelf.log.debug "  Unlocking #{name}"
          lockfile.unlock(name, true)
        end
      end

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
    # @raise [LockfileNotFound]
    #   if there is no lockfile
    # @raise [CookbookNotFound]
    #   if a listed source could not be found
    #
    # @return [Hash<Dependency, CachedCookbook>]
    #   the list of dependencies as keys and the cached cookbook as the value
    def list
      validate_lockfile_present!
      validate_lockfile_trusted!
      validate_dependencies_installed!

      lockfile.graph.locks.values
    end

    # List of all the cookbooks which have a newer version found at a source
    # that satisfies the constraints of your dependencies.
    #
    # @return [Hash]
    #   a hash of cached cookbooks and their latest version grouped by their
    #   remote API source. The hash will be empty if there are no newer
    #   cookbooks for any of your dependencies (that still satisfy the given)
    #   constraints in the +Berksfile+.
    #
    # @example
    #   berksfile.outdated #=> {
    #     "nginx" => {
    #       "local" => #<Version 1.8.0>,
    #       "remote" => {
    #         #<Source uri: "https://supermarket.chef.io"> #=> #<Version 2.6.2>
    #       }
    #     }
    #   }
    def outdated(*names)
      validate_lockfile_present!
      validate_lockfile_trusted!
      validate_dependencies_installed!
      validate_cookbook_names!(names)

      lockfile.graph.locks.inject({}) do |hash, (name, dependency)|
        sources.each do |source|
          cookbooks = source.versions(name)

          latest = cookbooks.select do |cookbook|
            dependency.version_constraint.satisfies?(cookbook.version) &&
            Semverse::Version.coerce(cookbook.version) > dependency.locked_version
          end.sort_by { |cookbook| cookbook.version }.last

          unless latest.nil?
            hash[name] ||= {
              'local' => dependency.locked_version,
              'remote' => {
                source => Semverse::Version.coerce(latest.version)
              }
            }
          end
        end

        hash
      end
    end

    # Upload the cookbooks installed by this Berksfile
    #
    # @overload upload(names = [])
    #   @param [Array<String>] names
    #     the list of cookbooks (by name) to upload to the remote Chef Server
    #
    #
    # @overload upload(names = [], options = {})
    #   @param [Array<String>] names
    #     the list of cookbooks (by name) to upload to the remote Chef Server
    #   @param [Hash<Symbol, Object>] options
    #     the list of options to pass to the uploader
    #
    #   @option options [Boolean] :force (false)
    #     upload the cookbooks even if the version already exists and is frozen
    #     on the remote Chef Server
    #   @option options [Boolean] :freeze (true)
    #     freeze the uploaded cookbooks on the remote Chef Server so that it
    #     cannot be overwritten on future uploads
    #   @option options [Hash] :ssl_verify (true)
    #     use SSL verification while connecting to the remote Chef Server
    #   @option options [Boolean] :halt_on_frozen (false)
    #     raise an exception ({FrozenCookbook}) if one of the cookbooks already
    #     exists on the remote Chef Server and is frozen
    #   @option options [String] :server_url
    #     the URL (endpoint) to the remote Chef Server
    #   @option options [String] :client_name
    #     the client name for the remote Chef Server
    #   @option options [String] :client_key
    #     the client key (pem) for the remote Chef Server
    #
    #
    # @example Upload all cookbooks
    #   berksfile.upload
    #
    # @example Upload the 'apache2' and 'mysql' cookbooks
    #   berksfile.upload('apache2', 'mysql')
    #
    # @example Upload and freeze all cookbooks
    #   berksfile.upload(freeze: true)
    #
    # @example Upload and freeze the `chef-sugar` cookbook
    #   berksfile.upload('chef-sugar', freeze: true)
    #
    #
    # @raise [UploadFailure]
    #   if you are uploading cookbooks with an invalid or not-specified client key
    # @raise [DependencyNotFound]
    #   if one of the given cookbooks is not a dependency defined in the Berksfile
    # @raise [FrozenCookbook]
    #   if the cookbook being uploaded is a {metadata} cookbook and is already
    #   frozen on the remote Chef Server; indirect dependencies or non-metadata
    #   dependencies are just skipped
    #
    # @return [Array<CachedCookbook>]
    #   the list of cookbooks that were uploaded to the Chef Server
    def upload(*args)
      validate_lockfile_present!
      validate_lockfile_trusted!
      validate_dependencies_installed!

      Uploader.new(self, *args).run
    end

    # Package the given cookbook for distribution outside of berkshelf. If the
    # name attribute is not given, all cookbooks in the Berksfile will be
    # packaged.
    #
    # @param [String] path
    #   the path where the tarball will be created
    #
    # @raise [PackageError]
    #
    # @return [String]
    #   the path to the package
    def package(path)
      packager = Packager.new(path)
      packager.validate!

      outdir = Dir.mktmpdir do |temp_dir|
        Berkshelf.ui.mute { vendor(File.join(temp_dir, 'cookbooks')) }
        packager.run(temp_dir)
      end

      Berkshelf.formatter.package(outdir)
      outdir
    end

    # Install the Berksfile or Berksfile.lock and then sync the cached cookbooks
    # into directories within the given destination matching their name.
    #
    # @param [String] destination
    #   filepath to vendor cookbooks to
    #
    # @return [String, nil]
    #   the expanded path cookbooks were vendored to or nil if nothing was vendored
    def vendor(destination)
      Dir.mktmpdir('vendor') do |scratch|
        chefignore       = nil
        cached_cookbooks = install
        raw_metadata_files = []

        return nil if cached_cookbooks.empty?

        cached_cookbooks.each do |cookbook|
          Berkshelf.formatter.vendor(cookbook, destination)
          cookbook_destination = File.join(scratch, cookbook.cookbook_name)
          FileUtils.mkdir_p(cookbook_destination)

          # Dir.glob does not support backslash as a File separator
          src   = cookbook.path.to_s.gsub('\\', '/')
          files = FileSyncer.glob(File.join(src, '*'))

          chefignore = Ridley::Chef::Chefignore.new(cookbook.path.to_s) rescue nil
          chefignore.apply!(files) if chefignore

          unless cookbook.compiled_metadata?
            cookbook.compile_metadata(cookbook_destination)
          end

          raw_metadata_files << File::join(cookbook.cookbook_name, 'metadata.rb')

          FileUtils.cp_r(files, cookbook_destination)
        end

        # Don't vendor the raw metadata (metadata.rb). The raw metadata is
        # unecessary for the client, and this is required until compiled metadata
        # (metadata.json) takes precedence over raw metadata in the Chef-Client.
        #
        # We can change back to including the raw metadata in the future after
        # this has been fixed or just remove these comments. There is no
        # circumstance that I can currently think of where raw metadata should
        # ever be read by the client.
        #
        # - Jamie
        #
        # See the following tickets for more information:
        #
        #   * https://tickets.opscode.com/browse/CHEF-4811
        #   * https://tickets.opscode.com/browse/CHEF-4810
        FileSyncer.sync(scratch, destination, exclude: raw_metadata_files + EXCLUDED_VCS_FILES_WHEN_VENDORING)
      end

      destination
    end

    # Perform a validation with `Validator#validate` on each cached cookbook associated
    # with the Lockfile of this Berksfile.
    #
    # This function will return true or raise the first errors encountered.
    def verify
      validate_lockfile_present!
      validate_lockfile_trusted!
      Berkshelf.formatter.msg "Verifying (#{lockfile.cached.length}) cookbook(s)..."
      Validator.validate(lockfile.cached)
      true
    end

    # Visualize the current Berksfile as a "graph" using DOT.
    #
    # @param [String] outfile
    #   the name/path to outfile the file
    #
    # @return [String] path
    #   the path where the image was written
    def viz(outfile = nil)
      outfile = File.join(Dir.pwd, outfile || 'graph.png')

      validate_lockfile_present!
      validate_lockfile_trusted!
      Visualizer.from_lockfile(lockfile).to_png(outfile)
    end

    # Get the lockfile corresponding to this Berksfile. This is necessary because
    # the user can specify a different path to the Berksfile. So assuming the lockfile
    # is named "Berksfile.lock" is a poor assumption.
    #
    # @return [Lockfile]
    #   the lockfile corresponding to this berksfile, or a new Lockfile if one does
    #   not exist
    def lockfile
      @lockfile ||= Lockfile.from_berksfile(self)
    end

    private

      # Ensure the lockfile is present on disk.
      #
      # @raise [LockfileNotFound]
      #   if the lockfile does not exist on disk
      #
      # @return [true]
      def validate_lockfile_present!
        raise LockfileNotFound unless lockfile.present?
        true
      end

      # Ensure that all dependencies defined in the Berksfile exist in this
      # lockfile.
      #
      # @raise [LockfileOutOfSync]
      #   if there are dependencies specified in the Berksfile which do not
      #   exist (or are not satisifed by) the lockfile
      #
      # @return [true]
      def validate_lockfile_trusted!
        raise LockfileOutOfSync unless lockfile.trusted?
        true
      end

      # Ensure that all dependencies in the lockfile are installed on this
      # system. You should validate that the lockfile can be trusted before
      # using this method.
      #
      # @raise [DependencyNotInstalled]
      #   if the dependency in the lockfile is not in the Berkshelf shelf on
      #   this system
      #
      # @return [true]
      def validate_dependencies_installed!
        lockfile.graph.locks.each do |_, dependency|
          unless dependency.installed?
            raise DependencyNotInstalled.new(dependency)
          end
        end

        true
      end

      # Determine if any cookbooks were specified that aren't in our shelf.
      #
      # @param [Array<String>] names
      #   a list of cookbook names
      #
      # @raise [DependencyNotFound]
      #   if a cookbook name is given that does not exist
      def validate_cookbook_names!(names)
        missing = names - lockfile.graph.locks.keys

        unless missing.empty?
          raise DependencyNotFound.new(missing)
        end
      end
  end
end
