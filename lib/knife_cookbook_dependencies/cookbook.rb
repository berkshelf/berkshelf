require 'knife_cookbook_dependencies/alias'
require 'knife_cookbook_dependencies/knife_utils'
require 'knife_cookbook_dependencies/git'
require 'chef/knife/cookbook_site_download'
require 'chef/knife/cookbook_site_show'

module KnifeCookbookDependencies
  class Cookbook
    attr_reader :name, :version_constraints
    attr_accessor :locked_version

    DOWNLOAD_LOCATION = ENV["TMPDIR"] || '/tmp'

    def initialize *args
      @options = args.last.is_a?(Hash) ? args.pop : {}

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
    end

    def add_version_constraint constraint_string
      @version_constraints ||= []
      @version_constraints << DepSelector::VersionConstraint.new(constraint_string) unless @version_constraints.collect(&:to_s).include? constraint_string
    end

    def download(show_output = false)
      return if @downloaded
      return if !from_git? and downloaded_archive_exists?
      return if from_path? and !from_git?

      if from_git? 
        @git ||= KCD::Git.new(@options[:git])
        @git.clone
        @git.checkout(@options[:ref]) if @options[:ref]
        @options[:path] ||= @git.directory
      else
        csd = Chef::Knife::CookbookSiteDownload.new([name, latest_constrained_version.to_s, "--file", download_filename])
        self.class.rescue_404 do
          output = KCD::KnifeUtils.capture_knife_output(csd)
        end

        if show_output
          output.split(/\r?\n/).each { |x| KCD.ui.info(x) }
        end
      end

      @downloaded = true
    end

    def copy_to_cookbooks_directory
      FileUtils.mkdir_p KCD::COOKBOOKS_DIRECTORY

      target = File.join(KCD::COOKBOOKS_DIRECTORY, @name)
      FileUtils.rm_rf target
      FileUtils.cp_r full_path, target
      FileUtils.rm_rf File.join(target, '.git') if from_git?
    end

    # TODO: Clean up download repetition functionality here, in #download and the associated test.
    def unpack(location = unpacked_cookbook_path, options={ })
      return true if from_path?

      self.clean  if options[:clean]
      download    if options[:download]

      unless downloaded_archive_exists? or File.directory?(location)
        # TODO raise friendly error
        raise "Archive hasn't been downloaded yet"
      end

      if downloaded_archive_exists?
        Archive::Tar::Minitar.unpack(Zlib::GzipReader.new(File.open(download_filename)), location)
      end

      return true
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
      KCD.ui.fatal "No version available to fit the following constraints for #{@name}: #{version_constraints.inspect}\nAvailable versions: #{versions.inspect}"
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
        @cookbook_data ||= JSON.parse(KCD::KnifeUtils.capture_knife_output(css))
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
      File.read(metadata_filename)
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
