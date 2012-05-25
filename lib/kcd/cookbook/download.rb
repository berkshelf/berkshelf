module KnifeCookbookDependencies
  class Cookbook
    class Download
      def initialize(args, cookbook)
        cookbook.add_version_constraint(args[1])
      end
    end
  end
end
