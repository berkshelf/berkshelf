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
          raise "Did not succeed executing git; check the output above." unless $?.success?
        end
    end
  end
end
