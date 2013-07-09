module Berkshelf
  class Berksfile
    class << self
      def default_sources
        @default_sources ||= [ Source.new("http://api.berkshelf.com") ]
      end

      # @param [#to_s] file
      #   a path on disk to a Berksfile to instantiate from
      #
      # @return [Berksfile]
      def from_file(file)
        new(file).dsl_eval_file(file)
      rescue Errno::ENOENT => ex
        raise BerksfileNotFound, "No Berksfile or Berksfile.lock found at: #{file}"
      rescue => ex
        raise BerksfileReadError.new(ex)
      end
    end

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

    # @return [Array<Berkshelf::CachedCookbook>]
    attr_reader :cached_cookbooks

    # @param [String] path
    #   path on disk to the file containing the contents of this Berksfile
    def initialize(path)
      @filepath         = path
      @dependencies     = Hash.new
      @cached_cookbooks = nil
      @sources          = Array.new
    end

    # Add a cookbook dependency to the Berksfile to be retrieved and have it's dependencies recursively retrieved
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
    #   source "http://api.berkshelf.com"
    #   source "http://berks-api.riotgames.com"
    #
    # @param [String] api_url
    #   url for the api to add
    #
    # @raise [Berkshelf::InvalidSourceURI]
    #
    # @return [Array<SourceURI>]
    def source(api_url)
      new_source = Source.new(api_url)
      @sources.push(new_source) unless @sources.include?(new_source)
    end

    # @return [Array<SourceURI>]
    def sources
      @sources.empty? ? self.class.default_sources : @sources
    end

    # @todo remove in Berkshelf 4.0
    #
    # @raise [Berkshelf::DeprecatedError]
    def site(*args)
      raise Berkshelf::DeprecatedError.new "Your Berksfile contains a site location. Site locations have been " +
        " replaced by the source location. Please remove your site location and try again. For more information " +
        " visit https://github.com/RiotGames/berkshelf/wiki/deprecated-locations"
    end

    # @todo remove in Berkshelf 4.0
    #
    # @raise [Berkshelf::DeprecatedError]
    def chef_api(*args)
      raise Berkshelf::DeprecatedError.new "Your Berksfile contains a chef_api location. Chef API locations have " +
        " been replaced by the source location. Please remove your site location and try again. For more " +
        " information visit https://github.com/RiotGames/berkshelf/wiki/deprecated-locations"
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

    # Find a dependency defined in this berksfile by name.
    #
    # @param [String] name
    #   the name of the cookbook dependency to search for
    # @return [Berkshelf::Dependency, nil]
    #   the cookbook dependency, or nil if one does not exist
    def find(name)
      @dependencies[name]
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
    #   if the lockfile constraints do not satisfy the Berskfile constraints
    # @raise [Berkshelf::ArgumentError]
    #   if there are missing or conflicting options
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

    # Get a list of all the cookbooks which have newer versions found on the community
    # site versus what your current constraints allow
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
    # @return [Hash]
    #   a hash of cached cookbooks and their latest version. An empty hash is returned
    #   if there are no newer cookbooks for any of your dependencies
    #
    # @example
    #   berksfile.outdated => {
    #     #<CachedCookbook name="artifact"> => "0.11.2"
    #   }
    def outdated(options = {})
      outdated = Hash.new

      dependencies(options).each do |dependency|
        if dependency.location
          # explicit locations check there
        else
          # check api
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
    #
    # @raise [UploadFailure]
    #   if you are uploading cookbooks with an invalid or not-specified client key
    # @raise [Berkshelf::FrozenCookbook]
    #   if an attempt to upload a cookbook which has been frozen on the target server is made
    #   and the :halt_on_frozen option was true
    def upload(options = {})
      options = options.reverse_merge(force: false, freeze: true, halt_on_frozen: false)

      cached_cookbooks = install(options)
      upload_opts      = options.slice(:force, :freeze)
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
          lockfile.dependencies.each { |dependency| cookbook_versions[dependency.name] = dependency.locked_version.to_s }
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
    # @option options [Boolean] :ignore_chefignore
    #   do not apply the chefignore file to the packed cookbooks
    #
    # @return [String]
    #   the path to the package
    def package(name = nil, options = {})
      tar_name = "#{name || 'package'}.tar.gz"
      output   = File.expand_path(File.join(options[:output], tar_name))

      cached_cookbooks = unless name.nil?
        unless dependency = find(name)
          raise CookbookNotFound, "Cookbook '#{name}' is not in your Berksfile"
        end

        options[:cookbooks] = name
        Berkshelf.ui.mute { install(options) }
      else
        Berkshelf.ui.mute { install(options) }
      end

      cached_cookbooks.each { |cookbook| validate_files!(cookbook) }

      Dir.mktmpdir do |tmp|
        cached_cookbooks.each do |cookbook|
          path        = cookbook.path.to_s
          destination = File.join(tmp, cookbook.cookbook_name)

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
        ridley_options[:server_url]  = options[:server_url] || Berkshelf.config.chef.chef_server_url
        ridley_options[:client_name] = Berkshelf.config.chef.node_name
        ridley_options[:client_key]  = Berkshelf.config.chef.client_key
        ridley_options[:ssl]         = { verify: (options[:ssl_verify] || Berkshelf.config.ssl.verify) }

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
        missing = (Array(options[:cookbooks]) - dependencies.map(&:name))
        unless missing.empty?
          raise Berkshelf::CookbookNotFound,
            "Could not find cookbook(s) #{missing.collect{ |c| "'#{c}'" }.join(', ')} " +
            "in any of the configured dependencies. #{missing.size == 1 ? 'Is it' : 'Are they' } in your Berksfile?"
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
