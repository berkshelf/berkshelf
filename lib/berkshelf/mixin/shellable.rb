require 'hashie'

module Berkshelf
  # @author Seth Vargo <sethvargo@gmail.com>
  module Shellable
    # Perform a cross-platform shell command, returning the process result.
    # This uses Process.spawn under the hood for Ruby 1.9, so see
    # {Process.spawn} for more information.
    #
    # On JRuby, a system command is used and $stdout and $stderr are captured.
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
    def shell_out(command)
      if defined?(RUBY_PLATFORM) && RUBY_PLATFORM == 'java' # jruby
        out, err, e = capture do
          system(command)
        end
      else
        begin
          out_file, err_file = Tempfile.new('berkshelf.stdout'), Tempfile.new('berkshelf.stderr')
          pid = Process.spawn({}, command, out: out_file.to_i, err: err_file.to_i)
          Process.waitpid(pid)

          out, err = File.read(out_file), File.read(err_file)
          e = $?
        rescue Errno::ENOENT
          out, err = "", "command not found: #{command}"
          e = $?
        end
      end

      Hashie::Mash.new({
        stdout:         out.strip,
        stderr:         err.strip,
        exitstatus:     e.exitstatus,
        pid:            e.pid,
        success?:       e.success?,
        failure?:       !e.success?
      })
    end

    private
      # Execute the given block, capturing $stdout, $stderr, and the returned process.
      #
      # @return [Array<StringIO, StringIO, Process>]
      #   a tuple of $stdout, $stderr, and the Process
      def capture(&block)
        out, err = StringIO.new, StringIO.new
        $stdout, $stderr = out, err

        yield

        out.rewind
        err.rewind
        return out.read, err.read, $?
      ensure
        $stdout, $stderr = STDOUT, STDERR
      end
  end
end
