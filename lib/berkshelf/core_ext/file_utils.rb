require "fileutils"

module FileUtils
  class << self
    alias_method :old_mv, :mv

    # If we encounter Errno::EACCES, which seems to happen occasionally on Windows,
    # try to copy and delete the file instead of moving it.
    #
    # @see https://github.com/berkshelf/berkshelf/issues/140
    # @see http://www.ruby-forum.com/topic/1044813
    #
    # It's also possible that we get Errno::ENOENT if we try to `mv` a relative
    # symlink on Linux
    # @see {FileUtils::mv}
    def mv(src, dest, options = {})
      old_mv(src, dest, options)
    rescue Errno::EACCES, Errno::ENOENT
      options.delete(:force) if options.has_key?(:force)
      FileUtils.cp_r(src, dest, options)
      FileUtils.rm_rf(src)
    end
  end
end
