module Berkshelf
  class Git
    class << self
      def git(*command)
        out = quietly {
          %x{ #{git_cmd} #{command.join(' ')} }
        }
        error_check
        
        out.chomp
      end

      def clone(uri, destination = Dir.mktmpdir)
        git("clone", uri, destination.to_s)

        error_check

        destination
      end

      def checkout(repo_path, ref)
        Dir.chdir repo_path do
          git("checkout", "-q", ref)
        end
      end

      def rev_parse(repo_path)
        Dir.chdir repo_path do
          git("rev-parse", "HEAD")
        end
      end

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

      private

        def git_cmd
          @git_cmd ||= find_git
        end

        def error_check
          raise Berkshelf::GitError, "Did not succeed executing git; check the output above." unless $?.success?
        end
    end
  end
end
