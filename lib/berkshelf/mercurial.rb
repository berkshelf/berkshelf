require 'uri'
require 'buff/shell_out'

module Berkshelf
  class Mercurial
    HG_REGEXP = URI.regexp(%w(http https file))

    HAS_QUOTE_RE = %r{\"}.freeze
    HAS_SPACE_RE = %r{\s}.freeze

    class << self
      include Buff::ShellOut

      # @overload hg(commands)
      #   Shellout to the Mercurial executable on your system with the given commands.
      #
      #   @param [Array<String>]
      #
      #   @return [String]
      #     the output of the execution of the Mercurial command
      def hg(*command)
        command.unshift(hg_cmd)
        command_str = command.map { |p| quote_cmd_arg(p) }.join(' ')
        response    = shell_out(command_str)

        unless response.success?
          raise MercurialError.new(response.stderr.strip)
        end

        response.stdout.strip
      end

      # Clone a remote Mercurial repository to disk
      #
      # @param [String] uri
      #   a Mercurial URI to clone
      # @param [#to_s] destination
      #   a local path on disk to clone to
      #
      # @return [String]
      #   the destination the URI was cloned to
      def clone(uri, destination = Dir.mktmpdir)
        hg('clone', uri, destination.to_s)
        destination
      end

      # Checkout the given revision in the given repository
      #
      # @param [String] repo_path
      #   path to a mercurial repo on disk
      # @param [String] rev
      #   revision to checkout
      def checkout(repo_path, rev)
        Dir.chdir repo_path do
          hg('update','--clean', '--rev', rev)
        end
      end

      # @param [String] repo_path
      def rev_parse(repo_path)
        Dir.chdir repo_path do
          hg('id', '-i')
        end
      end

      # Return an absolute path to the Mercurial executable on your system
      #
      # @return [String]
      #   absolute path to mercurial executable
      #
      # @raise [MercurialNotFound] if executable is not found in system path
      def find_hg
        hg_path = nil
        ENV['PATH'].split(::File::PATH_SEPARATOR).each do |path|
          hg_path = detect_hg_path(path)
          break if hg_path
        end

        unless hg_path
          raise MercurialNotFound
        end

        return hg_path
      end

      # Determines if the given URI is a valid Mercurial URI. A valid Mercurial URI is a string
      # containing the location of a Mercurial repository by HTTP or HTTPS
      #
      # @example Valid HTTPS URI
      #   'https://hghub.com/mryan/test'
      #
      # @param [String] uri
      #
      # @return [Boolean]
      def validate_uri(uri)

        unless uri.is_a?(String)
          return false
        end

        unless uri.slice(HG_REGEXP).nil?
          return true
        end

        false
      end

      # @raise [InvalidMercurialURI] if the given object is not a String containing a valid Mercurial URI
      #
      # @see validate_uri
      def validate_uri!(uri)
        unless validate_uri(uri)
          raise InvalidHgURI.new(uri)
        end

        true
      end

      private

      def hg_cmd
        @hg_cmd ||= find_hg
      end

      def quote_cmd_arg(arg)
        return arg if HAS_QUOTE_RE.match(arg)
        return arg unless HAS_SPACE_RE.match(arg)
        "\"#{arg}\""
      end

      def detect_hg_path(base_dir)
        %w(hg hg.exe hg.cmd).each do |hg_cmd|
          potential_path = File.join(base_dir, hg_cmd)
          if File.executable?(potential_path)
            return potential_path
          end
        end
        nil
      end
    end
  end
end
