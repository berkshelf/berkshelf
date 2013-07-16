require 'rubygems'
require 'rubygems/package'
require 'zlib'

module Berkshelf::Mixin
  module Tar
    def tar(path, options = {})
      path = path.to_s
      file = StringIO.new("")
      Gem::Package::TarWriter.new(file) do |tar|
        Dir[File.join(path, "**/*")].each do |file|
          mode          = File.stat(file).mode
          relative_path = file.sub /^#{Regexp::escape(path)}\/?/, ''

          if File.directory?(file)
            tar.mkdir(relative_path, mode)
          else
            tar.add_file(relative_path, mode) do |tar_file|
              File.open(file, "rb") { |f| tar_file.write(f.read) }
            end
          end
        end
      end

      file.rewind
      options[:gzip] ? gzip(file) : file
    end

    def gzip(tarfile)
      gstring = StringIO.new("")
      zwriter = Zlib::GzipWriter.new(gstring)
      zwriter.write(tarfile.string)
      zwriter.close
      StringIO.new(gstring.string)
    end
  end
end
