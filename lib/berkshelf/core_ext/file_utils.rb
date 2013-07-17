require 'fileutils'

module FileUtils
  class << self
    # Override mv to avoid several bugs (Errno::EACCES in Windows, Errno::ENOENT
    #   with relative softlinks on Linux), by forcing to copy and delete instead
    #
    # @see {FileUtils::mv}
    # @see {safe_mv}
    def mv(src, dest, options = {})
      FileUtils.cp_r(src, dest, options)
      FileUtils.rm_rf(src)
    end
  end
end
