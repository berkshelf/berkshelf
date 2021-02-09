require "mixlib/shellout" unless defined?(Mixlib::ShellOut)

module Berkshelf
  module ShellOut
    def shell_out(*args, **options)
      cmd = Mixlib::ShellOut.new(*args, **options)
      cmd.run_command
      cmd
    end

    def shell_out!(*args)
      cmd = shell_out(*args)
      cmd.error!
      cmd
    end
  end
end
