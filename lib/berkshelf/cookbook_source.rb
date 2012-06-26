module Berkshelf
  # @author Jamie Winsor <jamie@vialstudios.com>
  class CookbookSource
    module Location
      attr_reader :name

      # @param [#to_s] name
      def initialize(name)
        @name = name
        @downloaded_status = false
      end

      # @param [#to_s] destination
      #
      # @return [Berkshelf::CachedCookbook]
      def download(destination)
        raise NotImplementedError, "Function must be implemented on includer"
      end

      # @return [Boolean]
      def downloaded?
        @downloaded_status
      end

      private

        def set_downloaded_status(state)
          @downloaded_status = state
        end
    end

    extend Forwardable

    autoload :SiteLocation, 'berkshelf/cookbook_source/site_location'
    autoload :GitLocation, 'berkshelf/cookbook_source/git_location'
    autoload :PathLocation, 'berkshelf/cookbook_source/path_location'

    LOCATION_KEYS = [:git, :path, :site]

    attr_reader :name
    attr_reader :version_constraint
    attr_reader :groups
    attr_reader :location
    attr_reader :cached_cookbook

    def_delegators :@location, :downloaded?

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
      @cached_cookbook = nil

      if (options.keys & LOCATION_KEYS).length > 1
        raise ArgumentError, "Only one location key (#{LOCATION_KEYS.join(', ')}) may be specified"
      end

      options[:version_constraint] = version_constraint if version_constraint

      @location = case 
      when options[:git]
        GitLocation.new(name, options)
      when options[:path]
        PathLocation.new(name, options)
      when options[:site]
        SiteLocation.new(name, options)
      else
        SiteLocation.new(name, options)
      end

      @locked_version = DepSelector::Version.new(options[:locked_version]) if options[:locked_version]

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
      self.cached_cookbook = location.download(destination)
      [ :ok, cached_cookbook ]
    rescue CookbookNotFound => e
      self.cached_cookbook = nil
      [ :error, e.message ]
    end

    def has_group?(group)
      groups.include?(group.to_sym)
    end

    def locked_version
      @locked_version || cached_cookbook.version
    end

    def to_s
      "#{name} (#{version_constraint})"
    end

    private

      attr_writer :cached_cookbook

      def set_local_path(path)
        @local_path = path
      end
  end
end
