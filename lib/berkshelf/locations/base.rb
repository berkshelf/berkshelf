module Berkshelf
  class BaseLocation
    attr_reader :dependency
    attr_reader :options

    def initialize(dependency, options = {})
      @dependency = dependency
      @options    = options
    end

    # Determine if this revision is installed.
    #
    # @return [Boolean]
    def installed?
      raise AbstractFunction,
        "#installed? must be implemented on #{self.class.name}!"
    end

    # Install the given cookbook. Subclasses that implement this method should
    # perform all the installation and validation steps required.
    #
    # @return [void]
    def install
      raise AbstractFunction,
        "#install must be implemented on #{self.class.name}!"
    end

    # The cached cookbook for this location.
    #
    # @return [CachedCookbook]
    def cached_cookbook
      raise AbstractFunction,
        "#cached_cookbook must be implemented on #{self.class.name}!"
    end

    # The lockfile representation of this location.
    #
    # @return [string]
    def to_lock
      raise AbstractFunction,
        "#to_lock must be implemented on #{self.class.name}!"
    end

    # Ensure the given {CachedCookbook} is valid
    #
    # @param [String] path
    #   the path to the possible cookbook
    #
    # @raise [NotACookbook]
    #   if the cookbook at the path does not have a metadata
    # @raise [CookbookValidationFailure]
    #   if given CachedCookbook does not satisfy the constraint of the location
    # @raise [MismatcheCookboookName]
    #   if the cookbook does not have a name or if the name is different
    #
    # @return [true]
    def validate_cached!(path)
      unless File.cookbook?(path)
        raise NotACookbook.new(path)
      end

      cookbook = CachedCookbook.from_path(path)

      unless @dependency.version_constraint.satisfies?(cookbook.version)
        raise CookbookValidationFailure.new(dependency, cookbook)
      end

      unless @dependency.name == cookbook.cookbook_name
        raise MismatchedCookbookName.new(dependency, cookbook)
      end

      true
    end
  end
end
