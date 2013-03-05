module Berkshelf
  # @author Jamie Winsor <reset@riotgames.com>
  class CookbookSource
    class << self
      @@valid_options = [:constraint, :locations, :group, :locked_version]
      @@location_keys = Hash.new

      # Returns an array of valid options to pass to the initializer
      #
      # @return [Array<Symbol>]
      def valid_options
        @@valid_options
      end

      # Returns an array of the registered source location keys. Every source
      # location is identified by a key (symbol) to differentiate which class
      # to instantiate for the location of a CookbookSource at initialization.
      #
      # @return [Array<Symbol>]
      def location_keys
        @@location_keys
      end

      # Add a option to the list of valid options
      # @see #valid_options
      #
      # @param [Symbol] option
      #
      # @return [Array<Symbol>]
      def add_valid_option(option)
        @@valid_options.push(option) unless @@valid_options.include?(option)
        @@valid_options
      end

      # Register a location key with the CookbookSource class
      # @see #location_keys
      #
      # @param [Symbol] location
      #
      # @raise [ArgumentError] if the location key has already been defined
      #
      # @return [Array<Symbol>]
      def add_location_key(location, klass)
        unless @@location_keys.has_key?(location)
          add_valid_option(location)
          @@location_keys[location] = klass
        end

        @@location_keys
      end

      def validate_options(options)
        invalid_options = (options.keys - valid_options)

        unless invalid_options.empty?
          invalid_options.collect! { |opt| "'#{opt}'" }
          raise InternalError, "Invalid options for Cookbook Source: #{invalid_options.join(', ')}."
        end

        if (options.keys & [:site, :path, :git]).size > 1
          invalid = (options.keys & [:site, :path, :git]).map { |opt| "'#{opt}" }
          raise InternalError, "Cannot specify #{invalid.to_sentence} for a Cookbook Source!"
        end

        true
      end
    end

    extend Forwardable

    attr_reader :name
    attr_reader :options
    attr_reader :version_constraint
    attr_writer :cached_cookbook

    #  @param [String] name
    #  @param [Hash] options
    #
    #  @option options [String, Solve::Constraint] constraint
    #    version constraint to resolve for this source
    #  @option options [String] :git
    #    the Git URL to clone
    #  @option options [String] :site
    #    a URL pointing to a community API endpoint
    #  @option options [String] :path
    #    a filepath to the cookbook on your local disk
    #  @option options [Symbol, Array] :group
    #    the group or groups that the cookbook belongs to
    #  @option options [String] :ref
    #    the commit hash or an alias to a commit hash to clone
    #  @option options [String] :branch
    #    same as ref
    #  @option options [String] :tag
    #    same as tag
    #  @option options [String] :locked_version
    def initialize(name, options = {})
      self.class.validate_options(options)

      @name = name
      @options = options

      @version_constraint = Solve::Constraint.new(options[:locked_version] || options[:constraint] || ">= 0.0.0")

      # Eager-load the cached_cookbook so exceptions are raised here an not down the line
      cached_cookbook

      add_group(options[:group]) if options[:group]
      add_group(:default) if groups.empty?
    end

    def add_group(*local_groups)
      local_groups = local_groups.first if local_groups.first.is_a?(Array)

      local_groups.each do |group|
        group = group.to_sym
        groups << group unless groups.include?(group)
      end
    end

    # Returns true if the cookbook source has already been downloaded. A cookbook
    # source is downloaded when a cached cookbook is present.
    #
    # @return [Boolean]
    def downloaded?
      !self.cached_cookbook.nil?
    end

    # Returns true if this CookbookSource has the given group.
    #
    # @return [Boolean]
    def has_group?(group)
      groups.include?(group.to_sym)
    end

    # Get the locked version of this cookbook. First check the instance variable
    # and then resort to the cached_cookbook for the version.
    #
    # This was formerly a delegator, but it would fail if the `@cached_cookbook`
    # was nil or undefined.
    #
    # @return [Solve::Version, nil]
    #   the locked version of this cookbook
    def locked_version
      @locked_version ||= begin
        return Solve::Version.new(options[:locked_version]) if options[:locked_version]
        cached_cookbook && cached_cookbook.version
      end
    end

    # The associated CachedCookbok for this CookbookSource. This will first check a
    # local file path if the :path option was provided, and then attempt to locate
    # the CachedCookbook from the CookbookStore (if it's already been downloaded).
    #
    # @return [Berkshelf::CachedCookbook, nil]
    def cached_cookbook
      @cached_cookbook ||= from_path || from_cache
    end

    # The location for this CookbookSource, such as a remote Chef Server, the
    # community API, :git, or a :path location. By default, this will be the
    # community API.
    #
    # @return [Berkshelf::Location]
    def location
      @location ||= Location.init(name, version_constraint, options)
    end

    # The list of groups this CookbookSource belongs to.
    #
    # @return [Array<Symbol>]
    def groups
      @groups ||= []
    end

    def to_s
      msg = "#{self.name} (#{self.version_constraint}) groups: #{self.groups}"
      msg << " location: #{self.location}" if self.location
      msg
    end

    def to_hash
      {}.tap do |h|
        h[:name]           = self.name
        h[:locked_version] = self.locked_version
        h[:location]       = self.location.to_hash if self.location
      end
    end

    def to_json
      MultiJson.dump(self.to_hash, pretty: true)
    end

    private

      # Attempt to load a CachedCookbook from a local file system path (if the :path
      # option was given). If one is found, the location and cached_cookbook is
      # updated. Otherwise, this method will raise a CookbookNotFound exception.
      #
      # @raises [Berkshelf::CookbookNotFound]
      #   if no CachedCookbook exists at the given path
      #
      # @return [Berkshelf::CachedCookbook]
      def from_path
        return nil unless options[:path]

        @location = PathLocation.new(name, version_constraint, path: options[:path])

        begin
          CachedCookbook.from_path(@location.path)
        rescue IOError
          raise Berkshelf::CookbookNotFound
        end
      end

      # Attempt to load a CachedCookbook from the local CookbookStore. This will save
      # the need to make an http request to download a cookbook we already have cached
      # locally.
      #
      # @return [Berkshelf::CachedCookbook, nil]
      def from_cache
        path = File.join(Berkshelf.cookbooks_dir, "#{name}-#{options[:locked_version]}")

        return nil unless File.exists?(path)

        @location = PathLocation.new(name, version_constraint, path: path)
        CachedCookbook.from_path(path, name: name)
      end
  end
end
