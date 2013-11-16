module Berkshelf
  module RSpec
    module Git
      require 'buff/shell_out'
      include Buff::ShellOut

      require_relative 'path_helpers'
      include Berkshelf::RSpec::PathHelpers

      def git_origin_for(repo, options = {})
        "file://#{generate_fake_git_remote("git@github.com/RiotGames/#{repo}.git", options)}/.git"
      end

      def generate_fake_git_remote(uri, options = {})
        name = uri.split('/').last || 'rspec_cookbook'
        name = name.gsub('.git', '')
        path = remotes.join(name)

        capture(:stdout) do
          Dir.chdir(remotes) { generate_git_cookbook(name) }

          Dir.chdir(path) do
            shell_out "git config receive.denyCurrentBranch ignore"
            shell_out "echo '# a change!' >> content_file"
            shell_out "git add ."
            shell_out "git commit -am 'A commit.'"

            options[:tags].each do |tag|
              shell_out "echo '#{tag}' > content_file"
              shell_out "git add content_file"
              shell_out "git commit -am '#{tag} content'"
              shell_out "git tag '#{tag}' 2> /dev/null"
            end if options[:tags]

            options[:branches].each do |branch|
              shell_out "git checkout -b #{branch} master 2> /dev/null"
              shell_out "echo '#{branch}' > content_file"
              shell_out "git add content_file"
              shell_out "git commit -am '#{branch} content'"
              shell_out "git checkout master 2> /dev/null"
            end if options[:branches]
          end
        end

        path
      end

      # Calculate the git sha for the given ref.
      #
      # @param [#to_s] repo
      #   the repository to show the ref for
      # @param [#to_s] ref
      #   the ref to show
      #
      # @return [String]
      def sha_for_ref(repo, ref)
        Dir.chdir(remote_path(repo)) do
          shell_out("git show-ref #{ref}").stdout.split(/\s/).first
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
        def generate_git_cookbook(name)
          FileUtils.mkdir_p(name)
          File.open(File.join(name, 'metadata.rb'), 'w') do |f|
            f.write("name '#{name}'\nversion '1.0.0'")
          end
          FileUtils.mkdir_p(File.join(name, 'recipes'))
          FileUtils.touch(File.join(name, 'recipes', 'default.rb'))

          # Berkshelf::Commands::CookbookCommand.run(nil, [
          #   '--no-bundler',
          #   '--no-chefspec',
          #   '--no-foodcritic',
          #   '--no-minitest',
          #   '--no-scmversion',
          #   '--no-test-kitchen',
          #   '--no-vagrant',
          #   name,
          # ])
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
