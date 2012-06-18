module KnifeCookbookDependencies
  class Cookbookfile
    include DSL

    class << self
      def from_file(file)
        content = File.read(file)
        read(content)
      rescue Errno::ENOENT => e
        raise CookbookfileNotFound, "No Cookbookfile or Cookbookfile.lock found at: #{file}."
      end

      def read(content)
        object = new
        object.instance_eval(content)

        object
      end

      # @param [Array] sources
      #   an array of sources to filter
      # @param [Array, Symbol] excluded
      #   an array of symbols or a symbol representing the group or group(s)
      #   to exclude
      #
      # @return [Array<KCD::CookbookSource>]
      #   an array of sources that are not members of the excluded group(s)
      def filter_sources(sources, excluded)
        excluded = Array(excluded)
        excluded.collect!(&:to_sym)

        sources.select { |source| (excluded & source.groups).empty? }
      end
    end

    def initialize
      @sources = Hash.new
    end

    # Add the given source to the sources array. A DuplicateSourceDefined
    # exception will be raised if a source is added whose name conflicts
    # with a source who has already been added.
    #
    # @param [KCD::CookbookSource] source
    #   the source to add
    #
    # @return [Array<KCD::CookbookSource]
    def add_source(source)
      raise DuplicateSourceDefined if has_source?(source)
      @sources[source.to_s] = source
    end

    # @param [#to_s] source
    #   the source to remove
    #
    # @return [KCD::CookbookSource]
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

    # @param [Hash] options
    #   a hash of options
    #
    #   Options:
    #     exclude: An array of groups to exclude from the returned Array
    #       of sources
    #
    # @return [Array<KCD::CookbookSource>]
    def sources(options = {})
      l_sources = @sources.collect { |name, source| source }.flatten

      if options[:exclude]
        self.class.filter_sources(l_sources, options[:exclude])
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
    #         #<KCD::CookbookSource @name="nginx">,
    #         #<KCD::CookbookSource @name="mysql">,
    #       ],
    #       skarner: [
    #         #<KCD::CookbookSource @name="nginx">
    #       ]
    #     }
    def groups
      {}.tap do |groups|
        @sources.each_pair do |name, source|
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
    # @return [KCD::CookbookSource]
    def [](name)
      @sources[name]
    end
    alias_method :get_source, :[]

    # @param [Hash] options
    #   a hash of options
    #   
    #   Options:
    #     without: An array of groups to exclude which will cause any sources
    #       marked as a member of the group to not be installed
    def install(options = {})
      if File.exist?(KCD::Lockfile::DEFAULT_FILENAME)
        filename = KCD::Lockfile::DEFAULT_FILENAME
        lockfile = true
      else
        filename = KCD::DEFAULT_FILENAME
        lockfile = false
      end

      resolver = Resolver.new(KCD.downloader, sources(exclude: options[:without]))
      resolver.resolve
      write_lockfile(resolver.sources) unless lockfile
    end

    # @param [String] chef_server_url
    #   the full URL to the Chef Server to upload to
    #
    #   Example:
    #     "https://api.opscode.com/organizations/vialstudios"
    #
    # @param [Hash] options
    #   a hash of options
    #
    #   Options:
    #     without: An array of groups to exclude which will cause any sources
    #       marked as a member of the group to not be installed
    #     force: Upload the Cookbook even if the version already exists and is
    #       frozen on the target Chef Server
    #     freeze: Freeze the uploaded Cookbook on the Chef Server so that it
    #       cannot be overwritten
    def upload(chef_server_url, options = {})
      uploader = Uploader.new(KCD.cookbook_store, chef_server_url)
      resolver = Resolver.new(KCD.downloader, sources(exclude: options[:without]))  

      resolver.resolve.each do |name, version|
        KCD.ui.info "Uploading #{name} (#{version}) to: #{chef_server_url}"
        uploader.upload!(name, version, options)
      end
    end

    private

      def write_lockfile(sources)
        KCD::Lockfile.new(sources).write
      end
  end
end
