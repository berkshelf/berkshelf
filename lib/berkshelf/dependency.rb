module Berkshelf
  class Dependency
    class << self
      # Returns the name of this cookbook (because it's the key in hash tables).
      #
      # @param [Dependency, #to_s] dependency
      #   the dependency to find the name from
      #
      # @return [String]
      #   the name of the cookbook
      def name(dependency)
        if dependency.is_a?(Dependency)
          dependency.name.to_s
        else
          dependency.to_s
        end
      end
    end

    DEFAULT_CONSTRAINT = '>= 0.0.0'.freeze

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
    attr_reader :version_constraint
    # @return [Source]
    attr_accessor :source

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

    # Set this dependency's constraint(s).
    #
    # @param [#to_s] constraint
    #   the constraint to set
    def version_constraint=(constraint)
      @version_constraint = Solve::Constraint.new(constraint.to_s)
    end

    def add_group(*local_groups)
      local_groups = local_groups.first if local_groups.first.is_a?(Array)

      local_groups.each do |group|
        group = group.to_sym
        groups << group unless groups.include?(group)
      end
    end

    # Determine if this dependency is installed. A dependency is "installed" if
    # the associated {CachedCookbook} exists on disk.
    #
    # @return [Boolean]
    def installed?
      !cached_cookbook.nil?
    end

    # Attempt to load the cached_cookbook for this dependency. For SCM/path
    # locations, this method delegates to {BaseLocation#cached_cookbook}. For
    # generic dependencies, this method tries attemps to load a matching
    # cookbook from the {CookbookStore}.
    #
    # @return [CachedCookbook, nil]
    def cached_cookbook
      return @cached_cookbook if @cached_cookbook

      @cached_cookbook = if location
        cookbook = location.cached_cookbook

        # If we have a cached cookbook, tighten our constraints
        if cookbook
          self.locked_version     = cookbook.version
          self.version_constraint = cookbook.version
        end

        cookbook
      else
        if locked_version
          CookbookStore.instance.cookbook(name, locked_version)
        else
          CookbookStore.instance.satisfy(name, version_constraint)
        end
      end

      if scm_location? || path_location?
        self.locked_version     = @cached_cookbook.version
        self.version_constraint = @cached_cookbook.version
      end

      @cached_cookbook
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
      location && location.scm_location?
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
      out = if path_location? || scm_location? || version_constraint.to_s == '>= 0.0.0'
        "  #{name}\n"
      else
        "  #{name} (#{version_constraint})\n"
      end

      out << location.to_lock if location
      out
    end
  end
end
