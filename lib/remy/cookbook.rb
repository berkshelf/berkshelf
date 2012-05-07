require 'remy/knife_utils'
require 'remy/git'
require 'chef/knife/cookbook_site_download'
require 'chef/knife/cookbook_site_show'

module Remy
  class Cookbook
    attr_reader :name, :version_constraint

    DOWNLOAD_LOCATION = ENV["TMPDIR"] || '/tmp'

    def initialize *args
      @options = args.last.is_a?(Hash) ? args.pop : {}

      if from_git? and from_path?
        raise "Invalid: path and git options provided to #{args[0]}. They are mutually exclusive."
      end

      @options[:path] = File.expand_path(@options[:path]) if from_path?
      @name, constraint_string = args
      @version_constraint = DepSelector::VersionConstraint.new(if from_path?
                                                                 "= #{version_from_metadata_file.to_s}"
                                                               else
                                                                 constraint_string
                                                               end)
    end

    def download(show_output = false)
      return if @downloaded
      return if !from_git? and downloaded_archive_exists?

      if from_git? 
        @git ||= Remy::Git.new(@options[:git])
        @git.clone
        @git.checkout(@options[:ref]) if @options[:ref]
        @options[:path] ||= @git.directory
      elsif from_path?
        return
      else
        csd = Chef::Knife::CookbookSiteDownload.new([name, latest_constrained_version.to_s, "--file", download_filename])
        output = Remy::KnifeUtils.capture_knife_output(csd)

        if show_output
          puts output
        end
      end

      @downloaded = true
    end

    def copy_to_cookbooks_directory
      FileUtils.mkdir_p Remy::COOKBOOKS_DIRECTORY

      target = File.join(Remy::COOKBOOKS_DIRECTORY, @name)
      FileUtils.rm_rf target
      FileUtils.cp_r full_path, target
    end

    # TODO: Clean up download repetition functionality here, in #download and the associated test.
    def unpack(location = unpacked_cookbook_path, do_clean = false, do_download = true)
      return true if from_path?
      self.clean(File.join(location, @name)) if do_clean
      download if do_download
      fname = download_filename
      if File.directory? location
        true # noop
      elsif downloaded_archive_exists?
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
      # TODO: may want to let the each loop select the version if we
      # put error messages for not finding an acceptable version, ie:
      # if the available version doesn't fit in the constraints we
      # have.
      return version_from_metadata_file if from_path? or from_git?

      versions.reverse.each do |v|
        return v if @version_constraint.include? v
      end
    end

    def versions
      return [version_from_metadata_file] if from_path? or from_git?
      cookbook_data['versions'].collect { |v| DepSelector::Version.new(v.split(/\//).last.gsub(/_/, '.')) }.sort
    end

    def version_from_metadata_file
      # TODO: make a generic metadata file reader to replace
      # dependencyreader and incorporate pulling the version as
      # well... knife probably has something like this I can use/steal
      DepSelector::Version.new(metadata_file.match(/version\s+\"([0-9\.]*)\"/)[1])
    end

    def cookbook_data
      css = Chef::Knife::CookbookSiteShow.new([@name])
      @cookbook_data ||= JSON.parse(Remy::KnifeUtils.capture_knife_output(css))
    end

    def download_filename
      return nil if from_path?
      File.join(DOWNLOAD_LOCATION, "#{@name}-#{latest_constrained_version}.tar.gz")
    end

    def unpacked_cookbook_path
      @options[:path] || File.join(File.dirname(download_filename), File.basename(download_filename, '.tar.gz'))
    end

    def full_path
      if @git
        unpacked_cookbook_path
      else
        File.join(unpacked_cookbook_path, @name)
      end
    end

    def metadata_filename
      File.join(full_path, "metadata.rb")
    end

    def metadata_file
      download
      unpack
      File.open(metadata_filename).read
    end

    def from_path?
      !!@options[:path]
    end

    def from_git?
      !!@options[:git]
    end

    def downloaded_archive_exists?
      download_filename && File.exists?(download_filename)
    end

    def clean(location = unpacked_cookbook_path)
      if @git
        @git.clean
      else
        FileUtils.rm_rf location
        FileUtils.rm_f download_filename
      end
    end

    def == other
      other.name == @name and other.version_constraint == @version_constraint
    end
  end
end
