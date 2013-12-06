require 'archive/tar/minitar'
require 'zlib'

module Berkshelf
  # A class for archiving and compressing directory containing one or more cookbooks.
  #
  # Example:
  #   Archiving a path containing the cookbooks:
  #     * "/path/to/cookbooks/my_face"
  #     * "/path/to/cookbooks/nginx"
  #
  #   irb> source   = "/path/to/cookbooks"
  #   irb> packager = Berkshelf::Packager.new("some/path/cookbooks.tar.gz")
  #   irb> packager.run(source) #=> "some/path/cookbooks.tar.gz"
  class Packager
    class << self
      def validate_destination(path)
        path = path.to_s
      end
    end

    # @return [String]
    attr_reader :out_file

    # @param [#to_s] out_file
    #   path to write the archive to
    def initialize(out_file)
      @out_file           = out_file.to_s
      @out_dir, @filename = File.split(@out_file)
    end

    # Archive the contents of given path
    #
    # @param [#to_s] source
    #   the filepath to archive the contents of
    #
    # @raise [PackageError]
    #   if an error is encountered while writing the out_file
    #
    # @return [String]
    #   path to the generated archive
    def run(source)
      Dir.chdir(source.to_s) do |dir|
        tgz = Zlib::GzipWriter.new(File.open(out_file, "wb"))
        Archive::Tar::Minitar.pack(".", tgz)
      end

      out_file
    rescue SystemCallError => ex
      raise PackageError, ex
    end

    # Validate that running the packager would be successful. Returns nil if would be
    # successful and raises an error if would not.
    #
    # @raise [PackageError]
    #   if running the packager would absolutely not result in a success
    #
    # @return [nil]
    def validate!
      raise PackageError, "Path is not a directory: #{out_dir}" unless File.directory?(out_dir)
      raise PackageError, "Directory is not writable: #{out_dir}" unless File.writable?(out_dir)
    end

    private

      # @return [String]
      attr_reader :out_dir

      # @return [String]
      attr_reader :filename
  end
end
