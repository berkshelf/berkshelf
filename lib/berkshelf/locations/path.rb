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
    # @return [String]
    #   the relative path relative to the target
    def relative_path
      my_path     = Pathname.new(options[:path]).expand_path
      target_path = Pathname.new(dependency.berksfile.filepath).expand_path
      target_path = target_path.dirname if target_path.file?

      new_path = my_path.relative_path_from(target_path).to_s

      return new_path if new_path.index('.') == 0
      "./#{new_path}"
    end

    # The fully expanded path of this cookbook on disk, relative to the
    # Berksfile.
    #
    # @return [String]
    def expanded_path
      parent = File.expand_path(File.dirname(dependency.berksfile.filepath))
      File.expand_path(relative_path, parent)
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
