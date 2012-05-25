require 'kcd/cookbook/path'

module KnifeCookbookDependencies
  class Cookbook
    class Git

      attr_reader :git

      def initialize(args, cookbook)
        @options = cookbook.options
        @git = KCD::Git.new(@options[:git])
        cookbook.add_version_constraint("= #{cookbook.version_from_metadata.to_s}")
      end

    end
  end
end
