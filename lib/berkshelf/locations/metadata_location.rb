module Berkshelf
  class MetadataLocation
    include Location

    set_location_key :metadata

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
      @path               = options[:path] || '.'
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

    # The string representation of Berkshelf.
    #
    # @return [String]
    def to_s
      "#<Berkshelf::MetadataLocation #{name}>"
    end

    # The detailed string representation of Berkshelf.
    #
    # @return [String]
    def inspect
      "#<Berkshelf::MetadataLocation #{name}, path: #{path}>"
    end

    # The user-format for this location>#
    #
    # @return [String]
    def info
      'metadata'
    end
  end
end
