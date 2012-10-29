require 'fileutils'

module FileUtils
  class << self
    alias_method :old_mv, :mv

    # Override mv to ensure {safe_mv} is run if we are on the Windows platform.
    #
    # @see {FileUtils::mv}
    # @see {safe_mv}
    def mv(src, dest, options = {})
      if windows?
        safe_mv(src, dest, options)
      else
        old_mv(src, dest, options)
      end
    end

    # If we encounter Errno::EACCES, which seems to happen occasionally on Windows, 
    # try to copy and delete the file instead of moving it.
    #
    # @see https://github.com/RiotGames/berkshelf/issues/140
    # @see http://www.ruby-forum.com/topic/1044813
    #
    # @param [String] src
    # @param [String] dest
    # @param [Hash] options
    #   @see {FileUtils::mv}
    def safe_mv(src, dest, options = {})
      FileUtils.mv(src, dest, options)
    rescue Errno::EACCES
      FileUtils.cp_r(src, dest)
      FileUtils.rm_rf(src)
    end
  end
end
