require 'thor'

module Berkshelf
  # Subclass the current shell (which is different based on the OS)
  Shell = Class.new(Thor::Base.shell) do
    # Mute the output of this instance of UI until {#unmute!} is called
    def mute!
      @mute = true
    end

    # Unmute the output of this instance of UI until {#mute!} is called
    def unmute!
      @mute = false
    end

    def say(*args)
      return if quiet?
      super(*args)
    end
    alias_method :info, :say

    def warn(message, color = :yellow)
      say(message, color)
    end

    def error(message, color = :red)
      message = set_color(message, *color) if color
      super(message)
    end
  end
end
