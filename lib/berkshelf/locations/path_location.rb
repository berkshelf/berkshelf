module Berkshelf
  # @author Jamie Winsor <jamie@vialstudios.com>
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
      def normalize_path(path, berksfile_path=nil)
        path = path.to_s
        expanded_path = File.expand_path(path)
        if Pathname.new(path).absolute?
          expanded_path
        elsif berksfile_path
          expanded_root = File.expand_path(File.dirname(berksfile_path))
          split_root = expanded_root.split(File::SEPARATOR)
          split_path = expanded_path.split(File::SEPARATOR)
          common = split_root & split_path
          ((['..'] * (split_root - common).size) + (split_path - common)).join(File::SEPARATOR)
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
      @path               = self.class.normalize_path(options[:path], options[:berksfile_path])
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
    end

    def to_hash
      super.merge(value: self.path)
    end

    def to_s
      "#{self.class.location_key}: '#{path}'"
    end
  end
end
