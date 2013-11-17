require 'archive/tar/minitar'

module Berkshelf
  #
  # Extracts the contents of a file, handling different compression methods
  # and errors.
  #
  class Extractor
    # @return [String]
    attr_reader :package

    #
    # Create a new Extractor object for the given file.
    #
    # @example using a file path
    #   Extractor.new('/path/to/file.tar.gz')
    #
    # @example using a +File+ object
    #   file = File.new('/path/to/file.tar.gz')
    #   Extractor.new(file)
    #
    # @param [String, File] package
    #   the package or path to the package on disk. If a +File+ is given,
    #   it will be closed automatically.
    #
    def initialize(package)
      if package.is_a?(String)
        @package = package
      else
        if package.respond_to?(:close)
          package.close unless package.closed?
        end

        @package = package.path
      end
    end

    #
    # Extract the contents of the package onto disk.
    #
    # @raise [UnknownCompressionType]
    #   if the downloaded file cannot be decompressed
    #
    # @param [String] destination
    #   the path to unpack the contents (default: [temporary directory])
    #
    # @return [String]
    #   the path where the files were extracted
    #
    def unpack!(destination = Dir.mktmpdir)
      return unpack_from_gzip(destination) if gzip_file?
      return unpack_from_tar(destination)  if tar_file?

      raise UnknownCompressionType.new(@package)
    end

    #
    # Unpack the package, gracefully handling all errors.#
    #
    # @see Extractor#unpack! for parameters
    #
    # @return [String, FalseClass]
    #   the path where the files were extracted, or +false+ if there was an
    #   error extracting the package.
    #
    def unpack(destination = Dir.mktmpdir)
      unpack!(destination)
    rescue
      false
    end

    private

      #
      # Check if the package is gzipped.
      #
      # @return [Boolean]
      #
      def gzip_file?
        # We cannot write "\x1F\x8B" because the default encoding of
        # ruby >= 1.9.3 is UTF-8 and 8B is an invalid in UTF-8.
        IO.binread(path, 2) == [0x1F, 0x8B].pack("C*")
      end

      #
      # Check if the package is a tarball.
      #
      # @return [Boolean]
      #
      def tar_file?
        IO.binread(path, 8, 257).to_s == "ustar\x0000"
      end

      #
      # Unpack the package, treating it as a gzipped bundle.
      #
      # @param [String] destination
      #   the path to extract the archive
      #
      # @return [String]
      #   the destination
      #
      def unpack_from_gzip(destination)
        file = File.open(@package, 'rb')

        begin
          zlib = Zlib::GzipReader.new(file)
          Archive::Tar::Minitar.unpack(zlib, destination)
        ensure
          file.close unless file.closed?
        end

        destination
      end

      #
      # Unpack the package, treating it as a tarball.
      #
      # @param [String] destination
      #   the path to extract the archive
      #
      # @return [String]
      #   the destination
      #
      def unpack_from_tar(destination)
        Archive::Tar::MiniTar.unpack(@package, destination)
        destination
      end

  end
end
