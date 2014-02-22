module Berkshelf
  module RSpec
    module Mercurial
      require 'buff/shell_out'
      include Buff::ShellOut

      require_relative 'path_helpers'
      include Berkshelf::RSpec::PathHelpers

      def mercurial_origin_for(repo, options = {})
        File.join("file://localhost", generate_fake_mercurial_remote(repo, options))
      end

      def generate_fake_mercurial_remote(uri, options = {})
        repo_path = remotes.join(uri)

        FileUtils.mkdir repo_path

        Dir.chdir(repo_path) do
          ENV['HGUSER'] = 'test_user'
          shell_out "hg init"
          shell_out "echo \"# a change!\" >> content_file"
          if options[:is_cookbook]
            shell_out "echo \"#cookbook\" >> metadata.rb"
          end
          shell_out "hg add ."
          shell_out "hg commit -m \"A commit.\""
          options[:tags].each do |tag|
            shell_out "echo \"#{tag}\" > content_file"
            shell_out "hg commit -m \"#{tag} content\""
            shell_out "hg tag \"#{tag}\""
          end if options.has_key? :tags
          options[:branches].each do |branch|
            shell_out "hg branch #{branch}"
            shell_out "echo \"#{branch}\" > content_file"
            shell_out "hg commit -m \"#{branch} content\""
            shell_out "hg up default"
          end if options.has_key? :branches
        end
        repo_path.to_path
      end

      # Calculate the id for the given mercurial rev.
      #
      # @param [#to_s] repo
      #   the repository to show the rev for
      # @param [#to_s] rev
      #   the revision to identify
      #
      # @return [String]
      def id_for_rev(repo, rev)
        Dir.chdir remote_path(repo) do
          shell_out("hg id -r '#{rev}'").stdout.split(' ').first.strip
        end
      end

      # The clone path the given repo.
      #
      # @param [#to_s] repo
      #   the name of the local repo
      #
      # @return [Pathname]
      #   the path to the clone
      def clone_path(repo)
        clones.join(repo.to_s)
      end

      # The clone path the remote repo.
      #
      # @param [#to_s] repo
      #   the name of the remote repo
      #
      # @return [Pathname]
      #   the path to the clone
      def remote_path(repo)
        remotes.join(repo.to_s)
      end

      private

        # The path to store the local git clones.
        #
        # @return [Pathname]
        def clones
          ensure_and_return(tmp_path.join('clones'))
        end

        # The path to store the git remotes.
        #
        # @return [Pathname]
        def remotes
          ensure_and_return(tmp_path.join('remotes'))
        end

        # Generate a cookbook by the given name.
        #
        # @param [#to_s] name
        #   the name of the cookbook to create
        # @param [Hash] options
        #   the list ooptions to pass to the generator
        def generate_mercurial_cookbook(name, options = {})
          options = {
              skip_vagrant: true,
              force: true,
          }.merge(options)

          Berkshelf::Cli.new.invoke(:cookbook, [name.to_s], options)
        end

        # Make sure the given path exists and return the path
        #
        # @param [#to_s] path
        #   the path to create and return
        #
        # @return [Pathname]
        def ensure_and_return(path)
          FileUtils.mkdir(path) unless File.exist?(path)
          return Pathname.new(path).expand_path
        end
    end
  end
end
