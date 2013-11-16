require 'rubygems/user_interaction'

module Berkshelf
  module Mutable
    #
    # Silence all output until further notice.
    #
    def mute!
      Berkshelf.ui = SilentUI.new
    end

    #
    # Unsilence output.
    #
    def unmute!
      Berkshelf.ui = UI.new
    end

    #
    # Mute the Berkshelf UI over the given block, suppressing all output.
    #
    # @example
    #   mute { chatty_method_call }
    #
    def mute
      Berkshelf.ui = SilentUI.new
      yield
    ensure
      Berkshelf.ui = UI.new
    end
  end

  # A totally silent (everything is written to a null stream) ui.
  class SilentUI < Gem::SilentUI
    include Mutable
  end

  # The generic base class for outputting information to the user.
  class UI < Gem::StreamUI
    include Mutable

    def initialize
      super($stdin, $stdout, $stderr, true)
    end
  end
end
