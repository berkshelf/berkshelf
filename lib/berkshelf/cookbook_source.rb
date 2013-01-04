module Berkshelf
  # @author Jamie Winsor <jamie@vialstudios.com>
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

        true
      end

      # Load a source from the given hash.
      #
      # @param [<Berkshelf::CookbookSource>] hash
      #   the hash to convert into a cookbook source
      def from_json(hash)
        name = hash.delete(:name)
        hash.delete(:location)
        hash[:constraint] = "=#{hash[:locked_version]}"
        new(name, hash)
      end
    end

    extend Forwardable

    attr_reader :name
    attr_reader :version_constraint
    attr_reader :groups
    attr_reader :location
    attr_accessor :cached_cookbook

    def_delegator :cached_cookbook, :version

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
      @name = name
      @version_constraint = Solve::Constraint.new(options[:constraint] || ">= 0.0.0")
      @groups = []
      @cached_cookbook = nil
      @location = nil
      @locked_version = Solve::Version.new(options[:locked_version]) if options[:locked_version]

      self.class.validate_options(options)

      unless (options.keys & self.class.location_keys.keys).empty?
        @location = Location.init(name, version_constraint, options)
      end

      # If the location is Path, resolve it locally. Otherwise, try to resolve it locally
      # from the cookbook store.
      if @location.is_a?(PathLocation)
        @cached_cookbook = CachedCookbook.from_path(location.path)
      else
        @cached_cookbook = ::Berkshelf.cookbook_store.satisfy(@name, @locked_version || @version_constraint)
        @location = Location.init(name, version_constraint, options)
      end

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

    # Returns true if the cookbook source has already been downloaded. A cookbook
    # source is downloaded when it exists in the cookbook store
    #
    # @return [Boolean]
    def downloaded?
      !self.cached_cookbook.nil?
    end

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
      @locked_version ||= (cached_cookbook && cached_cookbook.version)
    end

    def to_s
      "#<Berkshelf::CookbookSource: #{name} (#{version_constraint})>"
    end

    def inspect
      "#<Berkshelf::CookbookSource: #{name} (#{version_constraint}), groups: #{groups}, location: #{location}>"
    end

    def to_hash
      {}.tap do |h|
        h[:name]           = self.name
        h[:locked_version] = self.locked_version.to_s
        h[:location]       = self.location.to_hash if self.location
      end
    end

    def to_json
      MultiJson.dump(self.to_hash, pretty: true)
    end
  end
end
