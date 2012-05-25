module KnifeCookbookDependencies
  class CookbookSource
    # @internal
    module Location
      attr_reader :uri

      def initialize(uri)
        @uri = uri
      end

      def download
        raise NotImplemented, "Must implement on inheriting class"
      end

      def unpack
        raise NotImplemented, "Must implement on inheriting class"
      end
    end

    # @internal
    class SiteLocation
      include Location

      def download
        # download this
      end

      def unpack
        # unpack this
      end
    end

    # @internal
    class PathLocation
      include Location

      def download
        true
      end

      def unpack
        true
      end
    end

    # @internal
    class GitLocation
      include Location

      attr_reader :branch

      def initialize(uri, options)
        @uri = uri
        @branch = options[:branch] || options[:ref] || options[:tag]
      end

      def download
        @git ||= KCD::Git.new(@options[:git])
        @git.clone
        @git.checkout(@options[:ref]) if @options[:ref]
        @options[:path] ||= @git.directory
      end

      def unpack
        true
      end
    end

    OPSCODE_COMMUNITY_API = 'http://cookbooks.opscode.com/api/v1/cookbooks'.freeze

    attr_reader :name
    attr_reader :version_constraint
    attr_reader :groups
    attr_reader :location
    attr_reader :locked_version

    # TODO: describe how the options on this function work.
    #
    # @param [String] name
    # @param [String] version_constraint (optional)
    # @param [Hash] options (optional)
    def initialize(*args)
      options = args.last.is_a?(Hash) ? args.pop : {}
      name, constraint = args

      @name = name
      @version_constraint = DepSelector::VersionConstraint.new(constraint)
      @groups = []

      raise ArgumentError if (options.keys & [:git, :path, :site]).length > 1

      @location = case 
      when options[:git]
        GitLocation.new(options[:git], options)
      when options[:path]
        PathLocation.new(options[:path])
      when options[:site]
        SiteLocation.new(options[:site])
      else
        SiteLocation.new(OPSCODE_COMMUNITY_API)
      end

      @locked_version = DepSelector::Version.new(options[:locked_version]) if options[:locked_version]

      add_group(KnifeCookbookDependencies.shelf.active_group) if KnifeCookbookDependencies.shelf.active_group
      add_group(options[:group]) if options[:group]
      add_group(:default) if groups.empty?
    end

    def add_group(*groups)
      groups = groups.first if groups.first.is_a?(Array)
      groups.each do |group|
        group = group.to_sym
        @groups << group unless @groups.include?(group)
      end
    end
  end
end
