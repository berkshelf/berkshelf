module Berkshelf
  class UI < Thor::Shell::Color
    # Mute the output of this instance of UI until {#unmute!} is called
    def mute!
      @mute = true
    end

    # Unmute the output of this instance of UI until {#mute!} is called
    def unmute!
      @mute = false
    end

    def say(message, color = nil, force_new_line = (message.to_s !~ /( |\t)$/))
      return if quiet?

      super(message, color, force_new_line)
    end
    alias_method :info, :say

    def say_status(status, message, log_status = true)
      return if quiet?

      super(status, message, log_status)
    end

    def error(message, color = :red)
      return if quiet?

      message = set_color(message, *color) if color
      super(message)
    end
    alias_method :fatal, :error
  end
end
