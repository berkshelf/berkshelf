require 'remy/knife_utils'
require 'chef/knife/cookbook_site_download'
require 'chef/knife/cookbook_site_show'

module Remy
  class Cookbook
    attr_reader :name, :version_constraint

    DOWNLOAD_LOCATION = ENV["TMPDIR"] || '/tmp'

    def initialize name, constraint_string = ">= 0.0.0"
      @name = name
      @version_constraint = DepSelector::VersionConstraint.new(constraint_string)
    end

    def download(show_output = false)
      return if File.exists? download_filename
      
      csd = Chef::Knife::CookbookSiteDownload.new([name, latest_constrained_version.to_s, "--file", download_filename])
      output = Remy::KnifeUtils.capture_knife_output(csd)

      if show_output
        puts output
      end
    end

    # TODO: Clean up download repetition functionality here, in #download and the associated test.
    def unpack(location = unpacked_cookbook_path, do_clean = false, do_download = true)
      # TODO: jk: For the final move to the cookbooks dir, copy the
      # already unpacked directory from /tmp. We had to unpack it
      # there to read dependencies anyway. No sense burning time
      # reinflating the archive.
      self.clean(File.join(location, @name)) if do_clean
      download if do_download
      fname = download_filename
      if File.directory? location
        true # noop
      elsif File.exists? fname
        Remy.ui.info "Unpacking #{@name} to #{location}"
        Archive::Tar::Minitar.unpack(Zlib::GzipReader.new(File.open(fname)), location)
        true
      else
        # TODO: Raise friendly error message class
        raise "Archive hasn't been downloaded yet"
      end
    end

    def dependencies
      download
      unpack
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
      @cookbook_data ||= JSON.parse(Remy::KnifeUtils.capture_knife_output(css))
    end

    def download_filename
      File.join(DOWNLOAD_LOCATION, "#{@name}-#{latest_constrained_version}.tar.gz")
    end

    def unpacked_cookbook_path
      File.join(File.dirname(download_filename), File.basename(download_filename, '.tar.gz'))
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
