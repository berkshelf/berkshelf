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

      # Load a source from the given hash.
      #
      # @param [<Berkshelf::CookbookSource>] hash
      #   the hash to convert into a cookbook source
      def from_hash(hash)
        name = hash[:name]
        options = hash[:options]
        new(name, options)
      end
    end

    extend Forwardable

    # @return [Berkshelf::Berksfile]
    attr_reader :berksfile
    # @return [String]
    attr_reader :name
    # @return [Solve::Constraint]
    attr_reader :version_constraint
    # @return [Berkshelf::CachedCookbook]
    attr_accessor :cached_cookbook

    # @param [Berkshelf::Berksfile] berksfile
    #   the berksfile this source belongs to
    # @param [String] name
    #   the name of source
    #
    # @option options [String, Solve::Constraint] :constraint
    #   version constraint to resolve for this source
    # @option options [String] :git
    #   the Git URL to clone
    # @option options [String] :site
    #   a URL pointing to a community API endpoint
    # @option options [String] :path
    #   a filepath to the cookbook on your local disk
    # @option options [Symbol, Array] :group
    #   the group or groups that the cookbook belongs to
    # @option options [String] :ref
    #   the commit hash or an alias to a commit hash to clone
    # @option options [String] :branch
    #   same as ref
    # @option options [String] :tag
    #   same as tag
    # @option options [String] :locked_version
    def initialize(berksfile, name, options = {})
      @options = options

      self.class.validate_options(options)

      @berksfile          = berksfile
      @name               = name
      @locked_version     = Solve::Version.new(options[:locked_version]) if options[:locked_version]
      @version_constraint = Solve::Constraint.new(options[:locked_version] || options[:constraint] || ">= 0.0.0")

      @cached_cookbook, @location = cached_and_location(options)

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

    # Determine the CachedCookbook and Location information from the given options.
    #
    # @return [Array<CachedCookbook, Location>]
    def cached_and_location(options = {})
      from_path(options) || from_cache(options) || from_default(options)
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
      @locked_version ||= cached_cookbook.try(:version)
    end

    # The location for this CookbookSource, such as a remote Chef Server, the
    # community API, :git, or a :path location. By default, this will be the
    # community API.
    #
    # @return [Berkshelf::Location]
    def location
      @location
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
      options = @options.dup
      options[:locked_version] = locked_version.to_s
      options[:ref] = @location.branch if @location.respond_to?(:ref)

      {
        name: name.to_s,
        options: options.reject { |k,v| v.nil? || v.empty? }
      }
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
      def from_path(options = {})
        return nil unless options[:path]

        path     = File.expand_path(PathLocation.normalize_path(options[:path]), File.dirname(berksfile.filepath))
        location = PathLocation.new(name, version_constraint, path: path)
        cached   = CachedCookbook.from_path(location.path)

        [ cached, location ]
      rescue IOError => ex
        raise Berkshelf::CookbookNotFound, ex
      end

      # Attempt to load a CachedCookbook from the local CookbookStore. This will save
      # the need to make an http request to download a cookbook we already have cached
      # locally.
      #
      # @return [Berkshelf::CachedCookbook, nil]
      def from_cache(options = {})
        path = File.join(Berkshelf.cookbooks_dir, filename(options))
        return nil unless File.exists?(path)

        location = PathLocation.new(name, version_constraint, path: path)
        cached   = CachedCookbook.from_path(path, name: name)

        [ cached, location ]
      end

      # Use the default location, and a nil CachedCookbook. If there is no location
      # specified,
      #
      # @return [Array<nil, Location>]
      def from_default(options = {})
        if (options.keys & self.class.location_keys.keys).empty?
          location = nil
        else
          location = Location.init(name, version_constraint, options)
        end

        [ nil, location ]
      end

      # The hypothetical location of this CachedCookbook, if it were to exist.
      #
      # @return [String]
      def filename(options = {})
        "#{name}-#{options[:locked_version]}"
      end
  end
end
