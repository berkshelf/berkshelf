require 'uri'
require 'buff/shell_out'

module Berkshelf
  class Subversion
    SVN_REGEXP = URI.regexp(%w(http https svn svn+ssh))

    HAS_QUOTE_RE = %r{\"}.freeze
    HAS_SPACE_RE = %r{\s}.freeze

    class << self
      include Buff::ShellOut

      # @overload svn(commands)
      #   Shellout to the Subversion executable on your system with the given commands.
      #
      #   @param [Array<String>]
      #
      #   @return [String]
      #     the output of the execution of the Subversion command
      def svn(*command)
        command.unshift(svn_cmd)
        command_str = command.map { |p| quote_cmd_arg(p) }.join(' ')
        response    = shell_out(command_str)

        unless response.success?
          raise SubversionError.new(response.stderr.strip)
        end

        response.stdout.strip
      end

      # Create a local copy of a Subversion repository
      #
      # @param [String] uri
      #   a Subversion URI to checkout
      # @param [#to_s] destination
      #   a local path on disk to create the working copy in
      # @param [#to_s] revision
      #   revision to checkout
      #
      # @return [String]
      #   the destination the URI was cloned to
      def checkout(uri, destination = Dir.mktmpdir, revision = 'HEAD')
        svn('checkout', '-q', '--force', '-r', revision, uri, destination.to_s)

        destination
      end

      # @param [String] wc_path
      def rev_parse(wc_path)
        Dir.chdir wc_path do
          svn('info', '|', 'grep', 'Revision:', '|', 'sed', 's/Revision\: //g')
        end
      end

      # Return an absolute path to the Subversion executable on your system
      #
      # @return [String]
      #   absolute path to svn executable
      #
      # @raise [SubversionNotFound] if executable is not found in system path
      def find_svn
        svn_path = nil
        ENV['PATH'].split(::File::PATH_SEPARATOR).each do |path|
          svn_path = detect_svn_path(path)
          break if svn_path
        end

        unless svn_path
          raise SubversionNotFound
        end

        return svn_path
      end

      # Determines if the given URI is a valid Subversion URI. A valid Subversion URI is a string
      # containing the location of a Subversion repository by either the Subversion protocol,
      # SVN+SSH protocol, or HTTP(S) protocol.
      #
      # @param [String] uri
      #
      # @return [Boolean]
      def validate_uri(uri)

        unless uri.is_a?(String)
          return false
        end

        unless uri.slice(SVN_REGEXP).nil?
          return true
        end

        false
      end

      # @raise [InvalidSubversionURI] if the given object is not a String containing a valid Subversion URI
      #
      # @see validate_uri
      def validate_uri!(uri)
        unless validate_uri(uri)
          raise InvalidSubversionURI.new(uri)
        end

        true
      end

      private

        def svn_cmd
          @svn_cmd ||= find_svn
        end

        def quote_cmd_arg(arg)
          return arg if HAS_QUOTE_RE.match(arg)
          return arg unless HAS_SPACE_RE.match(arg)
          "\"#{arg}\""
        end

        def detect_svn_path(base_dir)
          %w(svn svn.exe svn.cmd).each do |svn_cmd|
            potential_path = File.join(base_dir, svn_cmd)
            if File.executable?(potential_path)
              return potential_path
            end
          end
          nil
        end
    end
  end
end
