module Berkshelf
  class Logger < Ridley::Logging::Logger
    alias_method :fatal, :error

    def deprecate(message)
      trace = caller.join("\n\t")
      warn "DEPRECATION WARNING: #{message}\n\t#{trace}"
    end

    # Log an exception and its backtrace to FATAL
    #
    # @param [Exception] ex
    def exception(ex)
      fatal("#{ex.class}: #{ex}")
      fatal(ex.backtrace.join("\n")) unless ex.backtrace.nil?
    end
  end
end
