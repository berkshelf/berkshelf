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
    def unpack do_download = true
      return true if File.exists? unpacked_cookbook_path
      download if do_download
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

    def metadata_file
      unpack
      File.open(File.join(unpacked_cookbook_path, @name, 'metadata.rb')).read
    end

    def clean
      FileUtils.rm_rf unpacked_cookbook_path
      FileUtils.rm_f download_filename
    end

    def == other
      other.name == @name and other.version_constraint == @version_constraint
    end
  end
end
