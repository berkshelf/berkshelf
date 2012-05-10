require 'knife_cookbook_dependencies/knife_utils'
require 'knife_cookbook_dependencies/git'
require 'chef/knife/cookbook_site_download'
require 'chef/knife/cookbook_site_show'

module KnifeCookbookDependencies
  class Cookbook
    attr_reader :name, :version_constraints, :groups
    attr_accessor :locked_version

    DOWNLOAD_LOCATION = ENV["TMPDIR"] || '/tmp'

    def initialize *args
      @options = args.last.is_a?(Hash) ? args.pop : {}
      @groups = [:default]

      if from_git? and from_path?
        raise "Invalid: path and git options provided to #{args[0]}. They are mutually exclusive."
      end

      @options[:path] = File.expand_path(@options[:path]) if from_path?
      @name, constraint_string = args

      add_version_constraint(if from_path?
                               "= #{version_from_metadata_file.to_s}"
                             else
                               constraint_string
                             end)
      @locked_version = DepSelector::Version.new(@options[:locked_version]) if @options[:locked_version]
      add_group(@options[:group]) if @options[:group]
    end

    def add_version_constraint constraint_string
      @version_constraints ||= []
      @version_constraints << DepSelector::VersionConstraint.new(constraint_string) unless @version_constraints.collect(&:to_s).include? constraint_string
    end

    def download(show_output = false)
      return if @downloaded
      return if !from_git? and downloaded_archive_exists?

      if from_git? 
        @git ||= KnifeCookbookDependencies::Git.new(@options[:git])
        @git.clone
        @git.checkout(@options[:ref]) if @options[:ref]
        @options[:path] ||= @git.directory
      elsif from_path?
        return
      else
        csd = Chef::Knife::CookbookSiteDownload.new([name, latest_constrained_version.to_s, "--file", download_filename])
        self.class.rescue_404 do
          output = KnifeCookbookDependencies::KnifeUtils.capture_knife_output(csd)
        end

        if show_output
          puts output
        end
      end

      @downloaded = true
    end

    def copy_to_cookbooks_directory
      FileUtils.mkdir_p KnifeCookbookDependencies::COOKBOOKS_DIRECTORY

      target = File.join(KnifeCookbookDependencies::COOKBOOKS_DIRECTORY, @name)
      FileUtils.rm_rf target
      FileUtils.cp_r full_path, target
      FileUtils.rm_rf File.join(target, '.git') if from_git?
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
      @dependencies ||= DependencyReader.new(self).read
    end

    def latest_constrained_version
      return @locked_version if @locked_version
      return version_from_metadata_file if from_path? or from_git?

      versions.reverse.each do |v|
        return v if version_constraints_include? v
      end
      KnifeCookbookDependencies.ui.fatal "No version available to fit the following constraints for #{@name}: #{version_constraints.inspect}\nAvailable versions: #{versions.inspect}"
      exit 1
    end

    def version_constraints_include? version
      @version_constraints.inject(true) { |check, constraint| check and constraint.include? version }
    end

    def versions
      return [latest_constrained_version] if @locked_version
      return [version_from_metadata_file] if from_path? or from_git?
      cookbook_data['versions'].collect { |v| DepSelector::Version.new(v.split(/\//).last.gsub(/_/, '.')) }.sort
    end

    def version_from_metadata_file
      # TODO: make a generic metadata file reader to replace
      # dependencyreader and incorporate pulling the version as
      # well... knife probably has something like this I can use/steal
      DepSelector::Version.new(metadata_file.match(/version\s+[\"\']([0-9\.]*)[\"\']/)[1])
    end

    def cookbook_data
      css = Chef::Knife::CookbookSiteShow.new([@name])
      self.class.rescue_404 do
        @cookbook_data ||= JSON.parse(KnifeCookbookDependencies::KnifeUtils.capture_knife_output(css))
      end
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

    def git_repo
      @options[:git]
    end

    def git_ref
      (from_git? && @git) ? @git.ref : nil
    end

    def add_group(*groups)
      groups = groups.first if groups.first.is_a?(Array)
      groups.each do |group|
        group = group.to_sym
        @groups << group unless @groups.include?(group)
      end
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
      other.name == @name and other.version_constraints == @version_constraints
    end

    class << self
      def rescue_404
        begin
          yield
        rescue Net::HTTPServerException => e
          KnifeCookbookDependencies.ui.fatal ErrorMessages.missing_cookbook(@name) if e.message.match(/404/)
          exit 100
        end
      end
    end

  end
end
