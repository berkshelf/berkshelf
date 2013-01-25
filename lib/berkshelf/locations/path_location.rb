module Berkshelf
  # @author Jamie Winsor <jamie@vialstudios.com>
  class PathLocation
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
      @path               = PathLocation.normalize_path(options[:path])
      set_downloaded_status(true)
    end

    def self.normalize_path(path)
      if (path[0] == "~") || Pathname.new(path).absolute?
        File.expand_path(path)
      else
         path
      end
    end

    # @param [#to_s] destination
    #
    # @return [Berkshelf::CachedCookbook]
    def download(destination)
      cached = CachedCookbook.from_path(File.expand_path(path))
      validate_cached(cached)

      set_downloaded_status(true)
      cached
    end

    def to_hash
      super.merge(value: self.path)
    end

    def to_s
      "#{self.class.location_key}: '#{path}'"
    end
  end
end
