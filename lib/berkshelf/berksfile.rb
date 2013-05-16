module Berkshelf
  # @author Jamie Winsor <reset@riotgames.com>
  class Berksfile
    extend Forwardable
    include Berkshelf::Mixin::Logging

    class << self
      # @param [String] file
      #   a path on disk to a Berksfile to instantiate from
      #
      # @return [Berksfile]
      def from_file(file)
        content = File.read(file)
        object = new(file)
        object.load(content)
      rescue Errno::ENOENT => e
        raise BerksfileNotFound, "No Berksfile or Berksfile.lock found at: #{file}"
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
          dest = File.join(scratch, cb.cookbook_name, "/")
          FileUtils.mkdir_p(dest)

          # Dir.glob does not support backslash as a File separator
          src = cb.path.to_s.gsub('\\', '/')
          files = Dir.glob(File.join(src, "*"))

          # Filter out files using chefignore
          files = chefignore.remove_ignores_from(files) if chefignore

          FileUtils.cp_r(files, dest)
        end

        FileUtils.remove_dir(path, force: true)
        FileUtils.mv(scratch, path)

        path
      end
    end

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

    # Add a cookbook source to the Berksfile to be retrieved and have it's dependencies recursively retrieved
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

      metadata_file = Berkshelf.find_metadata(path)

      unless metadata_file
        raise CookbookNotFound, "No 'metadata.rb' found at #{path}"
      end

      metadata = Ridley::Chef::Cookbook::Metadata.from_file(metadata_file.to_s)

      name = if metadata.name.empty? || metadata.name.nil?
        File.basename(File.dirname(metadata_file))
      else
        metadata.name
      end

      constraint = "= #{metadata.version}"

      add_source(name, constraint, path: File.dirname(metadata_file))
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
    #   chef_api "https://api.opscode.com/organizations/vialstudios", node_name: "reset",
    #     client_key: "/Users/reset/.chef/knife.rb"
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

    # @option options [Symbol, Array] :except
    #   Group(s) to exclude to exclude from the returned Array of sources
    #   group to not be installed
    # @option options [Symbol, Array] :only
    #   Group(s) to include which will cause any sources marked as a member of the
    #   group to be installed and all others to be ignored
    # @option cookbooks [String, Array] :cookbooks
    #   Names of the cookbooks to retrieve sources for
    #
    # @raise [Berkshelf::ArgumentError] if a value for both :except and :only is provided
    #
    # @return [Array<Berkshelf::CookbookSource>]
    def sources(options = {})
      l_sources = @sources.collect { |name, source| source }.flatten

      cookbooks = Array(options.fetch(:cookbooks, nil))
      except    = Array(options.fetch(:except, nil)).collect(&:to_sym)
      only      = Array(options.fetch(:only, nil)).collect(&:to_sym)

      case
      when !except.empty? && !only.empty?
        raise Berkshelf::ArgumentError, "Cannot specify both :except and :only"
      when !cookbooks.empty?
        if !except.empty? && !only.empty?
          Berkshelf.ui.warn "Cookbooks were specified, ignoring :except and :only"
        end
        l_sources.select { |source| options[:cookbooks].include?(source.name) }
      when !except.empty?
        l_sources.select { |source| (except & source.groups).empty? }
      when !only.empty?
        l_sources.select { |source| !(only & source.groups).empty? }
      else
        l_sources
      end
    end

    # @return [Hash]
    #   a hash containing group names as keys and an array of CookbookSources
    #   that are a member of that group as values
    #
    #   Example:
    #     {
    #       nautilus: [
    #         #<Berkshelf::CookbookSource @name="nginx">,
    #         #<Berkshelf::CookbookSource @name="mysql">,
    #       ],
    #       skarner: [
    #         #<Berkshelf::CookbookSource @name="nginx">
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

    # @option options [Symbol, Array] :except
    #   Group(s) to exclude which will cause any sources marked as a member of the
    #   group to not be installed
    # @option options [Symbol, Array] :only
    #   Group(s) to include which will cause any sources marked as a member of the
    #   group to be installed and all others to be ignored
    # @option options [String] :path
    #   a path to "vendor" the cached_cookbooks resolved by the resolver. Vendoring
    #   is a technique for packaging all cookbooks resolved by a Berksfile.
    #
    # @return [Array<Berkshelf::CachedCookbook>]
    def install(options = {})
      resolver = Resolver.new(self, sources: sources(options))

      @cached_cookbooks = resolver.resolve
      write_lockfile(resolver.sources) unless lockfile_present?

      if options[:path]
        self.class.vendor(@cached_cookbooks, options[:path])
      end

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
      resolver = Resolver.new(self, sources: sources(options))

      cookbooks         = resolver.resolve
      sources           = resolver.sources
      missing_cookbooks = (options[:cookbooks] - cookbooks.map(&:cookbook_name))

      unless missing_cookbooks.empty?
        msg = "Could not find cookbooks #{missing_cookbooks.collect{|cookbook| "'#{cookbook}'"}.join(', ')}"
        msg << " in any of the sources. #{missing_cookbooks.size == 1 ? 'Is it' : 'Are they' } in your Berksfile?"
        raise Berkshelf::CookbookNotFound, msg
      end

      update_lockfile(sources)

      if options[:path]
        self.class.vendor(cookbooks, options[:path])
      end

      cookbooks
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
    #     <#CachedCookbook name="artifact"> => "0.11.2"
    #   }
    def outdated(options = {})
      outdated = Hash.new

      sources(options).each do |cookbook|
        location = cookbook.location || Location.init(cookbook.name, cookbook.version_constraint)

        if location.is_a?(SiteLocation)
          latest_version = location.latest_version

          unless cookbook.version_constraint.satisfies?(latest_version)
            outdated[cookbook] = latest_version
          end
        end
      end

      outdated
    end

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
    #
    # @raise [UploadFailure] if you are uploading cookbooks with an invalid or not-specified client key
    # @raise [Berkshelf::FrozenCookbook]
    #   if an attempt to upload a cookbook which has been frozen on the target server is made
    #   and the :halt_on_frozen option was true
    def upload(options = {})
      options = options.reverse_merge(
        force: false,
        freeze: true,
        ssl_verify: Berkshelf::Config.instance.ssl.verify,
        skip_dependencies: false,
        halt_on_frozen: false
      )

      ridley_options               = options.slice(:ssl)
      ridley_options[:server_url]  = options[:server_url] || Berkshelf::Config.instance.chef.chef_server_url
      ridley_options[:client_name] = Berkshelf::Config.instance.chef.node_name
      ridley_options[:client_key]  = Berkshelf::Config.instance.chef.client_key
      ridley_options[:ssl]         = { verify: options[:ssl_verify] }

      unless ridley_options[:server_url].present?
        raise UploadFailure, "Missing required attribute in your Berkshelf configuration: chef.server_url"
      end

      unless ridley_options[:client_name].present?
        raise UploadFailure, "Missing required attribute in your Berkshelf configuration: chef.node_name"
      end

      unless ridley_options[:client_key].present?
        raise UploadFailure, "Missing required attribute in your Berkshelf configuration: chef.client_key"
      end

      solution    = resolve(options)
      upload_opts = options.slice(:force, :freeze)
      conn        = Ridley.new(ridley_options)

      solution.each do |cb|
        Berkshelf.formatter.upload(cb.cookbook_name, cb.version, conn.server_url)

        validate_files!(cb)

        begin
          conn.cookbook.upload(cb.path, upload_opts.merge(name: cb.cookbook_name))
        rescue Ridley::Errors::FrozenCookbook => ex
          if options[:halt_on_frozen]
            raise Berkshelf::FrozenCookbook, ex
          end
        end
      end

      if options[:skip_dependencies]
        missing_cookbooks = options.fetch(:cookbooks, nil) - solution.map(&:cookbook_name)
        unless missing_cookbooks.empty?
          msg = "Unable to upload cookbooks: #{missing_cookbooks.sort.join(', ')}\n"
          msg << "Specified cookbooks must be defined within the Berkshelf file when using the"
          msg << " `--skip-dependencies` option"
          raise ExplicitCookbookNotFound.new(msg)
        end
      end
    rescue Ridley::Errors::RidleyError => ex
      log_exception(ex)
      raise UploadFailure, ex
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
    # @option options [Symbol, Array] :except
    #   Group(s) to exclude which will cause any sources marked as a member of the
    #   group to not be installed
    # @option options [Symbol, Array] :only
    #   Group(s) to include which will cause any sources marked as a member of the
    #   group to be installed and all others to be ignored
    # @option cookbooks [String, Array] :cookbooks
    #   Names of the cookbooks to retrieve sources for
    # @option options [Boolean] :skip_dependencies
    #   Skip resolving of dependencies
    #
    # @return [Array<Berkshelf::CachedCookbooks]
    def resolve(options = {})
      resolver(options).resolve
    end

    # Reload this instance of Berksfile with the given content. The content
    # is a string that may contain terms from the included DSL.
    #
    # @param [String] content
    #
    # @raise [BerksfileReadError] if Berksfile contains bad content
    #
    # @return [Berksfile]
    def load(content)
      begin
        instance_eval(content)
      rescue => e
        raise BerksfileReadError.new(e), "An error occurred while reading the Berksfile: #{e.to_s}"
      end
      self
    end

    private

      def descendant_directory?(candidate, parent)
        hack = FileUtils::Entry_.new('/tmp')
        hack.send(:descendant_diretory?, candidate, parent)
      end

      def lockfile_present?
        File.exist?(Berkshelf::Lockfile::DEFAULT_FILENAME)
      end

      # Builds a Resolver instance
      #
      # @option options [Symbol, Array] :except
      #   Group(s) to exclude which will cause any sources marked as a member of the
      #   group to not be installed
      # @option options [Symbol, Array] :only
      #   Group(s) to include which will cause any sources marked as a member of the
      #   group to be installed and all others to be ignored
      # @option options [String, Array] :cookbooks
      #   Names of the cookbooks to retrieve sources for
      # @option options [Boolean] :skip_dependencies
      #   Skip resolving of dependencies
      #
      # @return <Berkshelf::Resolver>
      def resolver(options = {})
        Resolver.new(self, sources: sources(options), skip_dependencies: options[:skip_dependencies])
      end

      def write_lockfile(sources)
        Berkshelf::Lockfile.new(sources).write
      end

      def update_lockfile(sources)
        Berkshelf::Lockfile.update!(sources)
      end

      # Validate that the given cookbook does not have "bad" files. Currently
      # this means including spaces in filenames (such as recipes)
      #
      # @param [Berkshelf::CachedCookbook] cookbook
      #  the Cookbook to validate
      def validate_files!(cookbook)
        path = cookbook.path.to_s

        files = Dir.glob(File.join(path, '**', '*.rb')).select do |f|
          f =~ /[[:space:]]/
        end

        raise Berkshelf::InvalidCookbookFiles.new(cookbook, files) unless files.empty?
      end
  end
end
