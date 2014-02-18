module Berkshelf
  class PathLocation < BaseLocation
    # A Path location is valid if the path exists and is readable by the
    # current process.
    #
    # @return (see BaseLocation#valid?)
    def valid?
      File.exist?(path) && File.readable?(path)
    end

    #
    #
    def download
      super(CachedCookbook.from_path(path, name: dependency.name))
    end

    # The path to the cookbook on disk.
    #
    # @return [String]
    def path
      options[:path]
    end

    # Returns true if the location is a metadata location. By default, no
    # locations are the metadata location.
    #
    # @return [Boolean]
    def metadata?
      !!options[:metadata]
    end

    # Return this PathLocation's path relative to the given target.
    #
    # @param [#to_s] target
    #   the path to a file or directory to be relative to
    #
    # @return [String]
    #   the relative path relative to the target
    def relative_path(target = '.')
      my_path     = Pathname.new(path).expand_path
      target_path = Pathname.new(target.to_s).expand_path
      target_path = target_path.dirname if target_path.file?

      new_path = my_path.relative_path_from(target_path).to_s

      return new_path if new_path.index('.') == 0
      "./#{new_path}"
    end

    #
    # The expanded path of this path on disk, relative to the berksfile.
    #
    # @return [String]
    #
    def expanded_path
      relative_path(dependency.berksfile.filepath)
    end

    # Valid if the path exists and is readable
    #
    # @return [Boolean]
    def valid?
      File.exist?(path) && File.readable?(path)
    end

    def to_hash
      super.merge(value: self.path)
    end

    def ==(other)
      other.is_a?(PathLocation) &&
      other.metadata? == metadata? &&
      other.expanded_path == expanded_path
    end

    def to_lock
      out =  "    path: #{relative_path(dependency.berksfile.filepath)}\n"
      out << "    metadata: true\n" if metadata?
      out
    end

    def to_s
      "source at #{relative_path(dependency.berksfile.filepath)}"
    end
  end
end
