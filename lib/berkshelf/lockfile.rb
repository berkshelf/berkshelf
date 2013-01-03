module Berkshelf
  class Lockfile
    class << self
      # Build a lockfile instance from the local .lock file.
      #
      # @raises Errno::ENOENT
      #   when the Lockfile cannot be found
      def load(filename)
        begin
          contents = File.read(filename)
        rescue Errno::ENOENT
          raise ::Berkshelf::LockfileNotFound, "Could not find a valid lock file at #{filename}"
        end

        Marshal.load(contents)
      end
    end

    # The name for the lockfile
    #
    # @example
    #   Berksfile.lock
    LOCKFILE_FILENAME = "#{Berkshelf::DEFAULT_FILENAME}.lock".freeze

    # Create a new lockfile instance from the given sources.
    #
    # @param [Array<Berkshelf::CookbookSource>] sources
    #   the list of cookbook sources
    # @param [Hash] options
    #   a list of options to pass to the lockfile
    attr_reader :sources

    def initialize(sources, options = {})
      @sources = sources
    end

    def save
      File.open(LOCKFILE_FILENAME, 'wb') do |file|
        file.write Marshal.dump(self)
      end
    end
    alias_method :write, :save

    # The last known sha of the the Berksfile from a successful install.
    #
    # This is used to quickly detect if the Berksfile has changed since the
    # last install.
    #
    # @return [String, nil]
    #   the last known SHA for the Berksfile
    def sha
      @sha ||= Berkshelf::Berksfile.sha
    end

    # Prepare this lockfile for marshaling
    def marshal_dump
      [sha, sources]
    end

    # Load the lockfile from marshal
    def marshal_load(data)
      @sha, @sources = data
    end
  end
end
