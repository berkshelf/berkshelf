require 'uri'

module Berkshelf
  # @author Jamie Winsor <jamie@vialstudios.com>
  class Git
    GIT_REGEXP = URI.regexp(%w{ https git })
    SSH_REGEXP = /(.+)@(.+):(.+)\/(.+)\.git/

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

      # Determines if the given URI is a valid Git URI. A valid Git URI is a string
      # containing the location of a Git repository by either the Git protocol,
      # SSH protocol, or HTTPS protocol.
      #
      # @example Valid Git protocol URI
      #   "git://github.com/reset/thor-foodcritic.git"
      # @example Valid HTTPS URI
      #   "https://github.com/reset/solve.git"
      # @example Valid SSH protocol URI
      #   "git@github.com:reset/solve.git"
      # 
      # @param [String] uri
      #
      # @return [Boolean]
      def validate_uri(uri)
        unless uri.is_a?(String)
          return false
        end

        unless uri.slice(SSH_REGEXP).nil?
          return true
        end

        unless uri.slice(GIT_REGEXP).nil?
          return true
        end

        false
      end

      # @raise [InvalidGitURI] if the given object is not a String containing a valid Git URI
      #
      # @see validate_uri
      def validate_uri!(uri)
        unless validate_uri(uri)
          raise InvalidGitURI.new(uri)
        end

        true
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
