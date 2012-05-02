module Remy
  class Cookbook
    attr_reader :name, :version_constraint

    DOWNLOAD_LOCATION = '/tmp'

    def initialize name, constraint_string=">= 0.0.0"
      @name = name
      @version_constraint = DepSelector::VersionConstraint.new(constraint_string)
    end

    def download
      return true if File.exists? download_filename
      download_command = "knife cookbook site download #{name}"
      download_command << " #{latest_constrained_version}"
      `#{download_command} --file #{download_filename}`
    end

    def unpack
      return true if File.exists? unpacked_cookbook_path
      download
      fname = download_filename
      if File.exists? fname
        Archive::Tar::Minitar.unpack(Zlib::GzipReader.new(File.open(fname)), unpacked_cookbook_path)
        true
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
        return v if @version_constraint.include? v #TODO: Confirm this works
      end
    end

    def versions
      cookbook_data['versions'].collect { |v| DepSelector::Version.new(v.split(/\//).last.gsub(/_/, '.')) }.sort
    end

    def cookbook_data
      command = "knife cookbook site show #{@name} --format json"
      @cookbook_data ||= JSON::parse(`#{command}`)
    end

    def download_filename
      File.join(DOWNLOAD_LOCATION, "#{@name}-#{latest_constrained_version}.tar.gz")
    end

    def unpacked_cookbook_path
      # Trimming File#extname doesn't handle the double file ext and will leave the .tar
      download_filename.gsub(/\.tar\.gz/, '')
    end

    def metadata_file
      unpack
      File.open(File.join(unpacked_cookbook_path, @name, 'metadata.rb')).read
    end

    def clean
      FileUtils.rm_rf unpacked_cookbook_path
    end

    def == other
      other.name == @name and other.version_constraint == @version_constraint
    end
  end
end
