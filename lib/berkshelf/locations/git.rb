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
      def initialize(command, path, stderr = nil)
        out =  "Git error: command `git #{command}` failed. If this error "
        out << "persists, try removing the cache directory at '#{path}'."

        if stderr
          out << "Output from the command:\n\n"
          out << stderr
        end

        super(out)
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
        Dir.chdir(cache_path) do
          git %|fetch --force --tags #{uri} "refs/heads/*:refs/heads/*"|
        end
      else
        git %|clone #{uri} "#{cache_path}" --bare --no-hardlinks|
      end

      Dir.chdir(cache_path) do
        @revision ||= git %|rev-parse #{ref}|
      end

      unless install_path.join('.git').exist?
        FileUtils.rm_rf(install_path)
        git %|clone --no-checkout "#{cache_path}" "#{install_path}"|
        install_path.chmod(0777 & ~File.umask)
      end

      Dir.chdir(install_path) do
        git %|fetch --force --tags "#{cache_path}"|
        git %|reset --hard #{@revision}|

        if rel
          git %|filter-branch --subdirectory-filter "#{rel}"|
        end
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
      out << "    ref: #{ref}\n"       if ref
      out << "    branch: #{branch}\n" if branch
      out << "    tag: #{tag}\n"       if tag
      out << "    rel: #{rel}\n"       if rel
      out
    end

    private

    # Perform a git command.
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
        raise GitCommandError.new(command, cache_path, stderr = response.stderr)
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
