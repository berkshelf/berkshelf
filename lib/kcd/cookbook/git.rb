require 'kcd/cookbook/common'

module KnifeCookbookDependencies
  class Cookbook
    class Git

      include KCD::Cookbook::Common::Prepare
      include KCD::Cookbook::Common::Unpack

      attr_reader :cookbook
      attr_reader :git

      def initialize(args, cookbook)
        @cookbook = cookbook
        @options  = cookbook.options
        @git = KCD::Git.new(@options[:git])
      end

      def download(show_output)
        @git.clone
        @git.checkout(@options[:ref]) if @options[:ref]
        @options[:path] ||= @git.directory
      end

      def full_path
        cookbook.unpacked_cookbook_path
      end

      def identifier
        cookbook.git_repo
      end

      def clean(location)
        @git.clean
      end
    end
  end
end
