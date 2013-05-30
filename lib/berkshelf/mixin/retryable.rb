require 'hashie'

module Berkshelf
  # @author Seth Vargo <sethvargo@gmail.com>
  module Retryable
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
    def retryable(options = {}, &block)
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
