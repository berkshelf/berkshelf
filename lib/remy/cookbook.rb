require 'chef/knife/cookbook_site_download'
require 'chef/knife/cookbook_site_show'

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
      
      csd = Chef::Knife::CookbookSiteDownload.new([name, latest_constrained_version.to_s, "--file", download_filename])
      csd.run

      csd.config[:file]
    end

    # TODO: Clean up download repetition functionality here, in #download and the associated test.
    def unpack(location = unpacked_cookbook_path, do_download = true)
      # TODO: jk: For the final move to the cookbooks dir, copy the
      # already unpacked directory from /tmp. We had to unpack it
      # there to read dependencies anyway. No sense burning time
      # reinflating the archive.
      self.clean(File.join(location, @name))
      download if do_download
      fname = download_filename
      if File.exists? fname
        Remy.ui.info "Unpacking #{@name} to #{location}"
        Archive::Tar::Minitar.unpack(Zlib::GzipReader.new(File.open(fname)), location)
        true
      else
        # TODO: Raise friendly error message class
        raise "Archive hasn't been downloaded yet"
      end
    end

    def dependencies
      @dependencies = DependencyReader.read self
    end

    def latest_constrained_version
      versions.reverse.each do |v|
        return v if @version_constraint.include? v
      end
    end

    def versions
      cookbook_data['versions'].collect { |v| DepSelector::Version.new(v.split(/\//).last.gsub(/_/, '.')) }.sort
    end

    def cookbook_data
      css = Chef::Knife::CookbookSiteShow.new([@name])
      # FIXME This UI Pattern should be abstracted.
      css.ui = Chef::Knife::UI.new(StringIO.new, StringIO.new, StringIO.new, { :format => :json })
      css.run
      css.ui.stdout.rewind
      @cookbook_data ||= JSON::parse(css.ui.stdout.read)
    end

    def download_filename
      File.join(DOWNLOAD_LOCATION, "#{@name}-#{latest_constrained_version}.tar.gz")
    end

    def unpacked_cookbook_path
      # Trimming File#extname doesn't handle the double file ext and will leave the .tar
      download_filename.gsub(/\.tar\.gz/, '')
    end

    def full_path
      File.join(unpacked_cookbook_path, @name)
    end

    def metadata_filename
      File.join(full_path, "metadata.rb")
    end

    def metadata_file
      unpack
      File.open(metadata_filename).read
    end

    def clean(location = unpacked_cookbook_path)
      FileUtils.rm_rf location
      FileUtils.rm_f download_filename
    end

    def == other
      other.name == @name and other.version_constraint == @version_constraint
    end
  end
end
