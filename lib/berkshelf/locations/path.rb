module Berkshelf
  class PathLocation < BaseLocation
    # Technically path locations are always installed, but this method
    # intentionally returns +false+ to force validation of the cookbook at the
    # path.
    #
    # @see BaseLocation#installed?
    def installed?
      false
    end

    # The installation for a path location is actually just a noop
    #
    # @see BaseLocation#install
    def install
      validate_cached!(expanded_path)
    end

    # @see BaseLocation#cached_cookbook
    def cached_cookbook
      @cached_cookbook ||= CachedCookbook.from_path(expanded_path)
    end

    # Returns true if the location is a metadata location. By default, no
    # locations are the metadata location.
    #
    # @return [Boolean]
    def metadata?
      !!options[:metadata]
    end

    # Return this PathLocation's path relative to the associated Berksfile. It
    # is actually the path reative to the associated Berksfile's parent
    # directory.
    #
    # @return [Pathname]
    #   the relative path relative to the target
    def relative_path
      @relative_path ||= expanded_path.relative_path_from(Pathname.new(File.dirname(dependency.berksfile.filepath)))
    end

    # The fully expanded path of this cookbook on disk, relative to the
    # Berksfile.
    #
    # @return [Pathname]
    def expanded_path
      @expanded_path ||= Pathname.new File.expand_path(options[:path], File.dirname(dependency.berksfile.filepath))
    end

    def ==(other)
      other.is_a?(PathLocation) &&
      other.metadata? == metadata? &&
      other.relative_path == relative_path
    end

    def to_lock
      out =  "    path: #{relative_path}\n"
      out << "    metadata: true\n" if metadata?
      out
    end

    def to_s
      "source at #{relative_path}"
    end

    def inspect
      "#<Berkshelf::PathLocation metadata: #{metadata?}, path: #{relative_path}>"
    end
  end
end
