require 'zlib'
require 'archive/tar/minitar'
require 'chef/knife/cookbook_site_download'

module Remy
  class Cookbook
    attr_reader :name, :requirement

    DOWNLOAD_LOCATION = '/tmp'

    def initialize name, requirement_string=">= 0"
      @name = name
      @requirement = Gem::Requirement.create(requirement_string)
    end

    def download
      download_command = "knife cookbook site download #{name}"
      download_command << " #{latest_constrained_version}" unless @requirement.nil?
      `#{download_command} --file #{download_filename}`
    end

    def unpack
      fname = download_filename
      if File.exists? fname
        Archive::Tar::Minitar.unpack(Zlib::GzipReader.new(File.open(fname)), unpacked_cookbook_path)
      else
        # TODO: Raise friendly error message class
        raise "Archive hasn't been downloaded yet"
      end
    end

    def dependencies
      # unpack # TODO: unpack unless already unpacked
      @dependencies = DependencyReader.read self
    end

    def latest_constrained_version
      versions.reverse.each do |v|
        return v if @requirement.satisfied_by? v
      end
    end

    def versions
      cookbook_data['versions'].collect { |v| Gem::Version.new(v.split(/\//).last.gsub(/_/, '.')) }.sort
    end

    def cookbook_data
      @cookbook_data ||= JSON::parse(`knife cookbook site show #{@name} --format json`)
    end

    def download_filename
      File.join(DOWNLOAD_LOCATION, "#{@name}-#{latest_constrained_version}.tar.gz")
    end

    def unpacked_cookbook_path
      # Trimming File#extname doesn't handle the double file ext and will leave the .tar
      File.join(download_filename.gsub(/\.tar\.gz/, ''), @name)
    end

    def metadata_file
      File.open(File.join(unpacked_cookbook_path, 'metadata.rb')).read
    end

    def == other
      other.name == @name and other.requirement == @requirement
    end
  end
end
