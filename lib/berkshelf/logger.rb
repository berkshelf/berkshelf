module Berkshelf
  Logger = Ridley.logger

  Logger.class_eval do
    alias_method :fatal, :error

    def deprecate(message)
      trace = caller.join("\n\t")
      warn "DEPRECATION WARNING: #{message}\n\t#{trace}"
    end
  end
end
