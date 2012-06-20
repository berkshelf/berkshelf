module KnifeCookbookDependencies
  class CookbookSource
    module Location
      attr_reader :name

      def initialize(name)
        @name = name
      end

      def download(destination)
        raise NotImplementedError, "Function must be implemented on includer"
      end
    end

    autoload :SiteLocation, 'kcd/cookbook_source/site_location'
    autoload :GitLocation, 'kcd/cookbook_source/git_location'
    autoload :PathLocation, 'kcd/cookbook_source/path_location'

    LOCATION_KEYS = [:git, :path, :site]

    attr_reader :name
    attr_reader :version_constraint
    attr_reader :groups
    attr_reader :location
    attr_reader :local_path

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
      @local_path = nil

      if (options.keys & LOCATION_KEYS).length > 1
        raise ArgumentError, "Only one location key (#{LOCATION_KEYS.join(', ')}) may be specified"
      end

      options[:version_constraint] = version_constraint if version_constraint

      @location = case 
      when options[:git]
        GitLocation.new(name, options)
      when options[:path]
        loc = PathLocation.new(name, options)
        set_local_path loc.path
        loc
      when options[:site]
        SiteLocation.new(name, options)
      else
        SiteLocation.new(name, options)
      end

      @locked_version = DepSelector::Version.new(options[:locked_version]) if options[:locked_version]

      add_group(options[:group]) if options[:group]
      add_group(:default) if groups.empty?
      set_downloaded_status(false)
    end

    def add_group(*groups)
      groups = groups.first if groups.first.is_a?(Array)
      groups.each do |group|
        group = group.to_sym
        @groups << group unless @groups.include?(group)
      end
    end

    # @param [String] destination
    #   destination to download to
    #
    # @return [Array]
    #   An array containing the status at index 0 and local path or error message in index 1
    #
    #   Example:
    #     [ :ok, "/tmp/nginx" ]
    #     [ :error, "Cookbook 'sparkle_motion' not found at site: http://cookbooks.opscode.com/api/v1/cookbooks" ]
    def download(destination)
      set_local_path location.download(destination)
      [ :ok, local_path ]
    rescue CookbookNotFound => e
      set_local_path = nil
      [ :error, e.message ]
    end

    def downloaded?
      !local_path.nil?
    end

    def metadata
      return nil unless local_path

      cookbook_metadata = Chef::Cookbook::Metadata.new
      cookbook_metadata.from_file(File.join(local_path, "metadata.rb"))
      cookbook_metadata
    end

    def to_s
      name
    end

    def has_group?(group)
      groups.include?(group.to_sym)
    end

    def dependencies
      return nil unless metadata

      metadata.dependencies
    end

    def local_version
      return nil unless metadata

      metadata.version
    end

    def locked_version
      @locked_version || local_version
    end

    private

      def set_downloaded_status(state)
        @downloaded_state = state
      end

      def set_local_path(path)
        @local_path = path
      end
  end
end
