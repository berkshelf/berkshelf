require 'hashie'

module Berkshelf
  module Util
    # @author Seth Vargo <sethvargo@gmail.com>
    # @author Jamie Winsor <reset@riotgames.com>
    class << self
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

      # Retry the given block
      #
      # @param [Hash] options
      #   a list of options
      #
      # @option options [Fixnum] :tries
      #   the number of times to retry
      # @option options [Fixnum] :sleep
      #   the amount of time to sleep between runs
      # @option options [Class] :on
      #   the error to retry on (all other errors are raised)
      def retry(options = {}, &block)
        options = { tries: 3, sleep: 0.5, on: Exception }.merge(options)
        return if options[:tries] == 0

        options[:on] = Array(options[:on])
        retries = 0
        retry_exception = nil

        begin
          return yield(retries, retry_exception)
        rescue *options[:on] => exception
          raise if retries > options[:tries]

          begin
            sleep(options[:sleep])
          rescue *options[:on]; end

          retries += 1
          return_exception = exception
          retry
        end
      end

      # Converts a path to a path usable for your current platform
      #
      # @param [String] path
      #
      # @return [String]
      def platform_specific_path(path)
        if RUBY_PLATFORM =~ /mswin|mingw|windows/
          system_drive = ENV['SYSTEMDRIVE'] ? ENV['SYSTEMDRIVE'] : ""
          path         = win_slashify File.join(system_drive, path.split('/')[2..-1])
        end

        path
      end

      # Convert a unixy filepath to a windowsy filepath. Swaps forward slashes for
      # double backslashes
      #
      # @param [String] path
      #   filepath to convert
      #
      # @return [String]
      #   converted filepath
      def win_slashify(path)
        path.gsub(File::SEPARATOR, (File::ALT_SEPARATOR || '\\'))
      end
    end
  end
end
