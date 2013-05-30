module Berkshelf
  # @author Jamie Winsor <reset@riotgames.com>
  module Loggable
    def log
      Berkshelf::Logger
    end

    # Log an exception and it's backtrace to FATAL
    #
    # @param [Exception] ex
    def log_exception(ex)
      log.fatal("#{ex.class}: #{ex}")
      log.fatal(ex.backtrace.join("\n")) unless ex.backtrace.nil?
    end
  end
end
