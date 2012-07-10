module Berkshelf
  # @author Jamie Winsor <jamie@vialstudios.com>
  class CookbookSource
    extend Forwardable

    autoload :Location, 'berkshelf/cookbook_source/location'
    autoload :SiteLocation, 'berkshelf/cookbook_source/site_location'
    autoload :GitLocation, 'berkshelf/cookbook_source/git_location'
    autoload :PathLocation, 'berkshelf/cookbook_source/path_location'

    LOCATION_KEYS = [:git, :path, :site]
    VALID_OPTIONS = [
      :git,
      :site,
      :path,
      :group,
      :ref,
      :branch,
      :tag,
      :locked_version
    ]

    attr_reader :name
    alias_method :to_s, :name

    attr_reader :version_constraint
    attr_reader :groups
    attr_reader :location
    attr_accessor :cached_cookbook

    def_delegator :@location, :downloaded?

    # @overload initialize(name, version_constraint, options = {})
    #   @param [#to_s] name
    #   @param [#to_s] version_constraint
    #   @param [Hash] options
    #
    #   @option options [String] :git
    #     the Git URL to clone
    #   @option options [String] :site
    #     a URL pointing to a community API endpoint
    #   @option options [String] :path
    #     a filepath to the cookbook on your local disk
    #   @option options [Symbol, Array] :group
    #     the group or groups that the cookbook belongs to
    #   @option options [String] :ref
    #     the commit hash or an alias to a commit hash to clone
    #   @option options [String] :branch
    #     same as ref
    #   @option options [String] :tag
    #     same as tag
    #   @option options [String] :locked_version
    # @overload initialize(name, options = {})
    #   @param [#to_s] name
    #   @param [Hash] options
    #
    #   @option options [String] :git
    #     the Git URL to clone
    #   @option options [String] :site
    #     a URL pointing to a community API endpoint
    #   @option options [String] :path
    #     a filepath to the cookbook on your local disk
    #   @option options [Symbol, Array] :group
    #     the group or groups that the cookbook belongs to
    #   @option options [String] :ref
    #     the commit hash or an alias to a commit hash to clone
    #   @option options [String] :branch
    #     same as ref
    #   @option options [String] :tag
    #     same as tag
    #   @option options [String] :locked_version
    def initialize(*args)
      options = args.last.is_a?(Hash) ? args.pop : {}
      name, constraint = args

      @name = name
      @version_constraint = Solve::Constraint.new(constraint || ">= 0.0.0")
      @groups = []
      @cached_cookbook = nil

      validate_options(options)

      @location = case 
      when options[:git]
        GitLocation.new(name, version_constraint, options)
      when options[:path]
        loc = PathLocation.new(name, version_constraint, options)
        @cached_cookbook = CachedCookbook.from_path(loc.path)
        loc
      when options[:site]
        SiteLocation.new(name, version_constraint, options)
      else
        SiteLocation.new(name, version_constraint, options)
      end

      @locked_version = Solve::Version.new(options[:locked_version]) if options[:locked_version]

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

      [ :ok, self.cached_cookbook ]
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

    private

      def set_local_path(path)
        @local_path = path
      end

      def validate_options(options)
        invalid_options = options.keys - VALID_OPTIONS

        unless invalid_options.empty?
          invalid_options.collect! { |opt| "'#{opt}'" }
          raise BerkshelfError, "Invalid options for Cookbook Source: #{invalid_options.join(', ')}."
        end

        if (options.keys & LOCATION_KEYS).length > 1
          raise BerkshelfError, "Only one location key (#{LOCATION_KEYS.join(', ')}) may be specified"
        end

        true
      end
  end
end
