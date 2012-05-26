require 'chef/knife/cookbook_site_download'
require 'chef/knife/cookbook_site_show'
require 'chef/cookbook/metadata'
require 'kcd/cookbook/download'
require 'kcd/cookbook/path'
require 'kcd/cookbook/git'

module KnifeCookbookDependencies
  class Cookbook
    attr_reader :name
    attr_reader :version_constraints
    attr_reader :groups
    attr_reader :options
    attr_reader :driver

    attr_accessor :locked_version

    DOWNLOAD_LOCATION = ::KCD::TMP_DIRECTORY || '/tmp'

    def initialize(*args)
      @options = args.last.is_a?(Hash) ? args.pop : {}
      @groups = []

      if from_git? and from_path?
        raise "Invalid: path and git options provided to #{args[0]}. They are mutually exclusive."
      end
      
      @name = args[0]

      if from_git?
        @driver = KCD::Cookbook::Git.new(args, self)
      elsif from_path?
        @driver = KCD::Cookbook::Path.new(args, self)
      else
        @driver = KCD::Cookbook::Download.new(args, self)
      end

      @driver.prepare
        
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

      @driver.download(show_output)
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
      @driver.identifier
    end

    def unpack(location = unpacked_cookbook_path, options={})
      @driver.unpack(location, options)
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
      return @driver.latest_constrained_version
    end

    def version_constraints_include?(version)
      @version_constraints.inject(true) { |check, constraint| check and constraint.include? version }
    end

    def versions
      return [latest_constrained_version] if @locked_version
      @driver.versions
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
      @driver.full_path
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
      @driver.clean(location)
    end

    def == other
      other.name == @name and other.version_constraints == @version_constraints
    end

    def rescue_404
      begin
        yield
      rescue Net::HTTPServerException => e
        KCD.ui.fatal ErrorMessages.missing_cookbook(@name) if e.message.match(/404/)
        exit 100
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
