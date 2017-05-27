require "berkshelf/shell_out"

module Berkshelf
  module Mixin
    module Git
      include Berkshelf::ShellOut
      # Perform a git command.
      #
      # @param [String] command
      #   the command to run
      # @param [Boolean] error
      #   whether to raise error if the command fails
      #
      # @raise [String]
      #   the +$stdout+ from the command
      def git(command, error = true)
        unless Berkshelf.which("git") || Berkshelf.which("git.exe") || Berkshelf.which("git.bat")
          raise GitNotInstalled.new
        end

        response = shell_out(%{git #{command}})

        if response.error?
          raise GitCommandError.new(command, cache_path, response.stderr)
        end

        response.stdout.strip
      end
    end
  end
end
