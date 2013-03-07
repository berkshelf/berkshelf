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

    # @param [#to_s] name
    # @param [Solve::Constraint] version_constraint
    # @param [Hash] options
    #
    # @option options [String] :path
    #   a filepath to the cookbook on your local disk
    def initialize(name, version_constraint, options = {})
      @name               = name
      @version_constraint = version_constraint
      @path               = self.class.normalize_path(options[:path])
      set_downloaded_status(true)
    end

    # @param [#to_s] destination
    #
    # @return [Berkshelf::CachedCookbook]
    def download(destination)
      cached = CachedCookbook.from_path(File.expand_path(path))
      validate_cached(cached)

      set_downloaded_status(true)
      cached
    rescue IOError
      raise Berkshelf::CookbookNotFound
    end

    def to_hash
      super.merge(value: self.path)
    end

    def to_s
      "#{self.class.location_key}: '#{path}'"
    end
  end
end
