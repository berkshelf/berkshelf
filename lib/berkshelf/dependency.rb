module Berkshelf
  class Dependency
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
      # to instantiate for the location of a Dependency at initialization.
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

      # Register a location key with the Dependency class
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
          raise InternalError, "Invalid options for dependency: #{invalid_options.join(', ')}."
        end

        if (options.keys & location_keys.keys).size > 1
          invalid = (options.keys & location_keys.keys).map { |opt| "'#{opt}'" }
          raise InternalError, "Cannot specify #{invalid.join(' and ')} for a dependency!"
        end

        true
      end
    end

    DEFAULT_CONSTRAINT = '>= 0.0.0'.freeze
    SCM_LOCATIONS      = [ :git, :github ].freeze

    # @return [Berkshelf::Berksfile]
    attr_reader :berksfile
    # @return [String]
    attr_reader :name
    # @return [Array<String,Symbol>]
    attr_reader :groups
    # @return [Berkshelf::Location]
    attr_reader :location
    # @return [Solve::Version]
    attr_reader :locked_version
    # @return [Solve::Constraint]
    attr_accessor :version_constraint
    # @return [Berkshelf::CachedCookbook]
    attr_accessor :cached_cookbook

    # @param [Berkshelf::Berksfile] berksfile
    #   the berksfile this dependency belongs to
    # @param [String] name
    #   the name of dependency
    #
    # @option options [String, Solve::Constraint] :constraint
    #   version constraint for this dependency
    # @option options [String] :git
    #   the Git URL to clone
    # @option options [String] :path
    #   a filepath to the cookbook on your local disk
    # @option options [String] :metadata
    #   use the metadata at the given pat
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
      self.class.validate_options(options)

      @options            = options
      @berksfile          = berksfile
      @name               = name
      @metadata           = options[:metadata]
      @location           = Location.init(self, options)
      @locked_version     = Solve::Version.new(options[:locked_version]) if options[:locked_version]
      @version_constraint = Solve::Constraint.new(options[:constraint] || DEFAULT_CONSTRAINT)

      add_group(options[:group]) if options[:group]
      add_group(:default) if groups.empty?
    end

    # Return true if this is a metadata location.
    #
    # @return [Boolean]
    def metadata?
      !!@metadata
    end

    # Set this dependency's locked version.
    #
    # @param [#to_s] version
    #   the version to set
    def locked_version=(version)
      @locked_version = Solve::Version.new(version.to_s)
    end

    def add_group(*local_groups)
      local_groups = local_groups.first if local_groups.first.is_a?(Array)

      local_groups.each do |group|
        group = group.to_sym
        groups << group unless groups.include?(group)
      end
    end

    # The cached (downloaded) cookbook for this dependency.
    #
    # @return [CachedCookbook, nil]
    def cached_cookbook
      @cached_cookbook ||= if location
        location.download
      else
        if locked_version
          CookbookStore.instance.cookbook(name, locked_version)
        else
          CookbookStore.instance.satisfy(name, version_constraint)
        end
      end
    end

    # Returns true if the dependency has already been downloaded. A dependency is downloaded when a
    # cached cookbook is present.
    #
    # @return [Boolean]
    def downloaded?
      !cached_cookbook.nil?
    end

    # Returns true if this dependency has the given group.
    #
    # @return [Boolean]
    def has_group?(group)
      groups.include?(group.to_sym)
    end

    # The location for this dependency, such as a remote Chef Server, the
    # community API, :git, or a :path location. By default, this will be the
    # community API.
    #
    # @return [Berkshelf::Location]
    def location
      @location
    end

    # The list of groups this dependency belongs to.
    #
    # @return [Array<Symbol>]
    def groups
      @groups ||= []
    end

    # Determines if this dependency has a location and is it a {PathLocation}
    #
    # @return [Boolean]
    def path_location?
      location.nil? ? false : location.is_a?(PathLocation)
    end

    # Determines if this dependency has a location and if it is an SCM location
    #
    # @return [Boolean]
    def scm_location?
      if location.nil?
        return false
      end

      SCM_LOCATIONS.include?(location.class.location_key)
    end

    def <=>(other)
      [self.name, self.version_constraint] <=> [other.name, other.version_constraint]
    end

    def to_s
      "#{name} (#{locked_version || version_constraint})"
    end

    def inspect
      '#<Berkshelf::Dependency: ' << [
        "#{name} (#{version_constraint})",
        "locked_version: #{locked_version.inspect}",
        "groups: #{groups}",
        "location: #{location || 'default'}>"
      ].join(', ')
    end

    def to_lock
      out = "  #{name}"

      if version_constraint.to_s == '>= 0.0.0'
        out << "\n"
      else
        out << " (#{version_constraint})\n"
      end

      if location.kind_of?(PathLocation)
        out << "    path: #{location.relative_path(berksfile.filepath)}\n"
      end

      if location.kind_of?(GitLocation)
        out << "    git: #{location.uri}\n"
        out << "    ref: #{location.ref}\n"
        out << "    rel: #{location.rel}\n" if location.rel
      end

      out
    end

    def to_hash
      {}.tap do |h|
        h[:locked_version] = locked_version.to_s

        if location.kind_of?(PathLocation)
          h[:path] = location.relative_path(berksfile.filepath)
        end

        if location.kind_of?(MercurialLocation)
          h[:hg] = location.uri
          h[:rev] = location.rev
          h[:rel] = location.rel if location.rel
        end

        if location.kind_of?(GitLocation)
          h[:git] = location.uri
          h[:ref] = location.ref
          h[:rel] = location.rel if location.rel
        end
      end.reject { |k,v| v.blank? }
    end

    def to_json(options = {})
      JSON.pretty_generate(to_hash, options)
    end
  end
end
