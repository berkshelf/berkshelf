require 'tempfile'

module Remy
  class Git
    class << self
      def git
        @git ||= find_git
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
        end

        unless git_path
          raise "Could not find git. Please ensure it is in your path."
        end

        return git_path
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
    end

    def clean
      FileUtils.rm_rf @directory if @directory
    end
  end
end
