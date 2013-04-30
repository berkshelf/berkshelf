module Berkshelf
  # @author Jamie Winsor <reset@riotgames.com>
  class PathLocation
    class << self
      # Expand and return a string representation of the given path if it is
      # absolute or a path in the users home directory.
      #
      # Returns the given relative path otherwise.
      #
      # @param [#to_s] path
      #
      # @return [String]
      def normalize_path(path)
        path = path.to_s
        if (path[0] == "~") || Pathname.new(path).absolute?
          File.expand_path(path)
        else
          path
        end
      end
    end

    include Location

    set_location_key :path

    attr_accessor :path
    attr_reader :name

    # @param [#to_s] name
    # @param [Solve::Constraint] version_constraint
    # @param [Hash] options
    #
    # @option options [String] :path
    #   a filepath to the cookbook on your local disk
    def initialize(name, version_constraint, options = {})
      @name               = name
      @version_constraint = version_constraint
      @path               = options[:path]
      set_downloaded_status(true)
    end

    # @param [#to_s] destination
    #
    # @return [Berkshelf::CachedCookbook]
    def download(destination)
      cached = CachedCookbook.from_path(path, name: name)
      validate_cached(cached)

      set_downloaded_status(true)
      cached
    rescue IOError
      raise Berkshelf::CookbookNotFound
    end

    def to_hash
      super.merge(value: self.path)
    end

    # The string representation of this PathLocation. If the path
    # is the default cookbook store, just leave it out, because
    # it's probably just cached.
    #
    # @example
    #   loc.to_s #=> artifact (1.4.0)
    #
    # @example
    #   loc.to_s #=> artifact (1.4.0) at path: '/Users/Seth/Dev/artifact'
    #
    # @return [String]
    def to_s
      if path.to_s.include?(berkshelf_path.to_s)
        "#{self.class.location_key}"
      else
        "#{self.class.location_key}: '#{path}'"
      end
    end
  end
end
