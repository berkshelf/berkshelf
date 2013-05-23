require 'hashie'

module Berkshelf
  module Util
    class << self
      # Perform a cross-platform shell command, returning the process result.
      # This uses Process.spawn under the hood, so see {Process.spawn} for more
      # information.
      #
      # @param [String] command
      # @param [Hash] options
      #   a list of options to send to {Process.spawn}
      # @return [Hashie::Mash]
      #   information about the command including:
      #     - stderr
      #     - stdout
      #     - exitstatus
      #     - pid
      #     - success?
      #     - failure?
      def shell_out(command, options = {})
        @stdout, @stderr = Tempfile.new('berkshelf.stdout'), Tempfile.new('berkshelf.stderr')
        options = { out: @stdout.to_i, err: @stderr.to_i }.merge(options)

        pid = Process.spawn(command, options)
        Process.waitpid(pid)

        Hashie::Mash.new({
          stdout:         File.read(@stdout).strip,
          stderr:         File.read(@stderr).strip,
          exitstatus:     $?.exitstatus,
          pid:            $?.pid,
          success?:       $?.success?,
          failure?:       !$?.success?
        })
      end
    end
  end
end
