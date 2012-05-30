require 'tempfile'
require 'shellwords'
require 'em-systemcommand'

module KnifeCookbookDependencies
  class Git
    class << self
      def git
        @git ||= find_git
      end
      alias_method :git_cmd, :git

      #
      # This is to defeat aliases/shell functions called 'git' and a number of
      # other problems.
      #
      def find_git
        git_path = nil
        ENV["PATH"].split(File::PATH_SEPARATOR).each do |path|
          potential_path = File.join(path, 'git')
          if File.executable?(potential_path)
            git_path = potential_path
            break
          end
          potential_path = File.join(path, 'git.exe')
          if File.executable?(potential_path)
            git_path = potential_path
            break
          end
        end

        unless git_path
          raise "Could not find git. Please ensure it is in your path."
        end

        return git_path
      end

      def clone(uri, destination = Dir.mktmpdir)
        quietly { system(git_cmd, "clone", uri, destination.to_s) }
        error_check

        destination
      end

      def checkout(repo_path, ref)
        Dir.chdir repo_path do
          quietly { system(git_cmd, "checkout", "-q", ref) }
        end

        ref
      end

      private

        def error_check
          if $?.exitstatus != 0
            raise "Did not succeed executing git; check the output above."
          end
        end
    end

    attr_reader :directory
    attr_reader :repository

    def initialize(repo)
      @repository = repo
    end

    def clone
      # XXX not sure how resilient this is, maybe a fetch/merge strategy would be better.
      if @directory
        Dir.chdir @directory do
          system(self.class.git, "pull")
        end
      else
        @directory = Dir.mktmpdir
        system(self.class.git, "clone", @repository, @directory)
      end

      error_check
    end

    def async_clone(path = Dir.mktmpdir)
      cmd = EM::SystemCommand.new("#{self.class.git} clone #{repository} #{path}")
      cmd.execute
    end

    def checkout(ref)
      clone

      Dir.chdir @directory do
        system(self.class.git, "checkout", "-q", ref)
      end

      error_check
    end

    def ref
      return nil unless @directory

      this_ref = nil

      Dir.chdir @directory do
        this_ref = `"#{self.class.git}" rev-parse HEAD`.strip
      end

      return this_ref
    end

    def clean
      FileUtils.rm_rf @directory if @directory
    end

    def error_check
      if $?.exitstatus != 0
        raise "Did not succeed executing git; check the output above."
      end
    end
  end
end
