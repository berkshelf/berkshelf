require 'chef/knife/cookbook_site_download'
require 'chef/knife/cookbook_site_show'
require 'chef/cookbook/metadata'

module KnifeCookbookDependencies
  class Cookbook
    attr_reader :name, :version_constraints, :groups
    attr_accessor :locked_version

    DOWNLOAD_LOCATION = ::KCD::TMP_DIRECTORY || '/tmp'

    def initialize(*args)
      @options = args.last.is_a?(Hash) ? args.pop : {}
      @groups = []

      if from_git? and from_path?
        raise "Invalid: path and git options provided to #{args[0]}. They are mutually exclusive."
      end

      @options[:path] = File.expand_path(@options[:path]) if from_path?
      @name, constraint_string = args

      add_version_constraint(if from_path?
                               "= #{version_from_metadata.to_s}"
                             else
                               constraint_string
                             end)
      @locked_version = DepSelector::Version.new(@options[:locked_version]) if @options[:locked_version]
      add_group(KnifeCookbookDependencies.shelf.active_group) if KnifeCookbookDependencies.shelf.active_group
      add_group(@options[:group]) if @options[:group]
      add_group(:default) if @groups.empty?
    end

    def add_version_constraint(constraint_string)
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
        FileUtils.mkdir_p KCD::TMP_DIRECTORY
        csd = Chef::Knife::CookbookSiteDownload.new([name, latest_constrained_version.to_s, "--file", download_filename])

        output = ''
        rescue_404 do
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
      KCD.ui.info "#{@name} (#{identifier})"
      FileUtils.rm_rf File.join(target, '.git') if from_git?
    end

    def identifier
      @git_repo || local_path || latest_constrained_version
    end

    # TODO: Clean up download repetition functionality here, in #download and the associated test.
    def unpack(location = unpacked_cookbook_path, options = {})
      return true if from_path?

      clean     if options[:clean]
      download  if options[:download]

      unless downloaded_archive_exists? or File.directory?(location)
        # TODO raise friendly error
        raise "Archive hasn't been downloaded yet"
      end

      if downloaded_archive_exists?
        Archive::Tar::Minitar.unpack(Zlib::GzipReader.new(File.open(download_filename, 'rb')), location)
      end

      return true
    end

    def dependencies
      download
      unpack

      unless @dependencies
        @dependencies = []
        metadata.dependencies.each { |name, constraint| depends(name, constraint) }
      end

      @dependencies
    end

    def latest_constrained_version
      return @locked_version if @locked_version
      return version_from_metadata if from_path? or from_git?

      versions.reverse.each do |v|
        return v if version_constraints_include? v
      end

      raise NoVersionForConstraints, "No version for #{@name} that met constraints: #{version_constraints.inspect}. Available versions: #{versions.inspect}"
    end

    def version_constraints_include?(version)
      @version_constraints.inject(true) { |check, constraint| check and constraint.include? version }
    end

    def versions
      return [latest_constrained_version] if @locked_version
      return [version_from_metadata] if from_path? or from_git?
      cookbook_data['versions'].collect { |v| DepSelector::Version.new(v.split(/\//).last.gsub(/_/, '.')) }.sort
    end

    def version_from_metadata
      DepSelector::Version.new(metadata.version)
    end

    def cookbook_data
      css = Chef::Knife::CookbookSiteShow.new([@name])
      rescue_404 do
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

    def metadata
      download
      unpack

      cookbook_metadata = Chef::Cookbook::Metadata.new
      cookbook_metadata.from_file(metadata_filename)
      cookbook_metadata
    end

    def local_path
      @options[:path]
    end

    def from_path?
      !!local_path
    end

    def from_git?
      !!git_repo
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

    def ==(other)
      other.name == @name and other.version_constraints == @version_constraints
    end

    def rescue_404
      begin
        yield
      rescue Net::HTTPServerException => e
        if e.message.match(/404/)
          raise RemoteCookbookNotFound, "Cookbook '#{@name}' not found on the Opscode Community site. Maybe use the git or path source if it's unpublished?"
        end
      end
    end

    private

      def depends(name, constraint = nil)
        dependency_cookbook = KCD.shelf.get_cookbook(name) || @dependencies.find { |c| c.name == name }
        if dependency_cookbook
          dependency_cookbook.add_version_constraint constraint
        else
          @dependencies << Cookbook.new(name, constraint) 
        end
      end
  end
end
