module Remy
  module DependencyReader
    class << self
      def read cookbook
        @dependency_list = []
        instance_eval cookbook.metadata_file
        @dependency_list
      end
      
      def depends *args
        @dependency_list << Cookbook.new(*args)
      end

      def method_missing method, *args
        # Don't blow up when other metadata DSL methods are called, we only care about #depends.
      end
    end
  end
end
