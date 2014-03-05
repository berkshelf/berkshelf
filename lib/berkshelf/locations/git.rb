require 'buff/shell_out'

module Berkshelf
  class GitLocation < BaseLocation
    class GitError < BerkshelfError; status_code(400); end

    class GitNotInstalled < GitError
      def initialize
        super 'You need to install Git before you can download ' \
          'cookbooks from git repositories. For more information, please ' \
          'see the Git docs: http://git-scm.org.'
      end
    end

    class GitCommandError < GitError
      def initialize(command, path = nil)
        super "Git error: command `git #{command}` failed. If this error " \
          "persists, try removing the cache directory at `#{path}'."
      end
    end

    attr_reader :uri
    attr_reader :branch
    attr_reader :tag
    attr_reader :ref
    attr_reader :revision
    attr_reader :rel

    def initialize(dependency, options = {})
      super

      @uri      = options[:git]
      @branch   = options[:branch]
      @tag      = options[:tag]
      @ref      = options[:ref] || options[:branch] || options[:tag] || 'master'
      @revision = options[:revision]
      @rel      = options[:rel]
    end

    def download
      if installed?
        cookbook = CachedCookbook.from_store_path(install_path)
        return super(cookbook)
      end

      if cached?
        # Update and checkout the correct ref
        Dir.chdir(cache_path) do
          git %|fetch --all|
        end
      else
        # Ensure the cache directory is present before doing anything
        FileUtils.mkdir_p(cache_path)

        Dir.chdir(cache_path) do
          git %|clone #{uri} .|
        end
      end

      Dir.chdir(cache_path) do
        git %|checkout #{revision || ref}|
        @revision ||= git %|rev-parse HEAD|
      end

      # Gab the path where we should copy from (since it might be relative to
      # the root).
      copy_path = rel ? cache_path.join(rel) : cache_path

      # Validate the thing we are copying is a Chef cookbook
      validate_cookbook!(copy_path)

      # Remove the current cookbook at this location (this is required or else
      # FileUtils will copy into a subdirectory in the next step)
      FileUtils.rm_rf(install_path)

      # Copy whatever is in the current cache over to the store
      FileUtils.cp_r(copy_path, install_path)

      # Remove the .git directory to save storage space
      if (git_path = install_path.join('.git')).exist?
        FileUtils.rm_r(git_path)
      end

      cookbook = CachedCookbook.from_store_path(install_path)
      super(cookbook)
    end

    def scm_location?
      true
    end

    def ==(other)
      other.is_a?(GitLocation) &&
      other.uri == uri &&
      other.branch == branch &&
      other.tag == tag &&
      other.ref == ref &&
      other.rel == rel
    end

    def to_s
      info = tag || branch || ref[0...7]

      if rel
        "#{uri} (at #{info}/#{rel})"
      else
        "#{uri} (at #{info})"
      end
    end

    def to_lock
      out =  "    git: #{uri}\n"
      out << "    revision: #{revision}\n"
      out << "    branch: #{branch}\n" if branch
      out << "    tag: #{tag}\n"       if tag
      out << "    rel: #{rel}\n"       if rel
      out
    end

    private

    # Perform a mercurial command.
    #
    # @param [String] command
    #   the command to run
    # @param [Boolean] error
    #   whether to raise error if the command fails
    #
    # @raise [String]
    #   the +$stdout+ from the command
    def git(command, error = true)
      unless Berkshelf.which('git') || Berkshelf.which('git.exe')
        raise GitNotInstalled.new
      end

      response = Buff::ShellOut.shell_out(%|git #{command}|)

      if error && !response.success?
        raise GitCommandError.new(command, cache_path)
      end

      response.stdout.strip
    end

    # Determine if this git repo has already been downloaded.
    #
    # @return [Boolean]
    def cached?
      cache_path.exist?
    end

    # Determine if this revision is installed.
    #
    # @return [Boolean]
    def installed?
      revision && install_path.exist?
    end

    # The path where this cookbook would live in the store, if it were
    # installed.
    #
    # @return [Pathname, nil]
    def install_path
      Berkshelf.cookbook_store.storage_path
        .join("#{dependency.name}-#{revision}")
    end

    # The path where this git repository is cached.
    #
    # @return [Pathname]
    def cache_path
      Pathname.new(Berkshelf.berkshelf_path)
        .join('.cache', 'git', Digest::SHA1.hexdigest(uri))
    end
  end
end
