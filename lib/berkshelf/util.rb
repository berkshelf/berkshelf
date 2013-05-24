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
    end
  end
end
