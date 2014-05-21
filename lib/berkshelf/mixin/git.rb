require 'buff/shell_out'

module Berkshelf
  module Mixin
    module Git
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
        unless Berkshelf.which('git') || Berkshelf.which('git.exe')
          raise GitNotInstalled.new
        end

        response = Buff::ShellOut.shell_out(%|git #{command}|)

        if error && !response.success?
          raise GitCommandError.new(command, cache_path, response.stderr)
        end

        response.stdout.strip
      end
    end
  end
end
