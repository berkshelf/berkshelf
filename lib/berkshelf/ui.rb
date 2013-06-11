module Berkshelf
  module UI
    # Mute the output of this instance of UI until {#unmute!} is called
    def mute!
      @mute = true
    end

    # Unmute the output of this instance of UI until {#mute!} is called
    def unmute!
      @mute = false
    end

    def say(message = '', color = nil, force_new_line = (message.to_s !~ /( |\t)\Z/))
      return if quiet?

      super(message, color, force_new_line)
    end

    # @see {say}
    def info(message = '', color = nil, force_new_line = (message.to_s !~ /( |\t)\Z/))
      say(message, color, force_new_line)
    end

    def say_status(status, message, log_status = true)
      return if quiet?

      super(status, message, log_status)
    end

    def warn(message, color = :yellow)
      return if quiet?

      say(message, color)
    end

    def deprecated(message)
      warn("[DEPRECATION] #{message}")
    end

    def error(message, color = :red)
      return if quiet?

      message = set_color(message, *color) if color
      super(message)
    end
    alias_method :fatal, :error
  end
end
