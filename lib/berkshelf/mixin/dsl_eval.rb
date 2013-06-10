module Berkshelf
  module Mixin
    module DSLEval
      class CleanRoom
        attr_reader :instance

        def initialize(instance)
          @instance = instance
        end
      end

      class << self
        def included(base)
          base.send(:extend, ClassMethods)
        end
      end

      module ClassMethods
        def clean_room
          @clean_room ||= begin
            exposed_methods = self.exposed_methods

            Class.new(DSLEval::CleanRoom) do
              exposed_methods.each do |exposed_method|
                define_method(exposed_method) do |*args|
                  instance.send(exposed_method, *args)
                end
              end
            end
          end
        end

        def expose_method(method)
          exposed_methods << method.to_sym
        end

        def exposed_methods
          @exposed_methods ||= Array.new
        end
      end

      def dsl_eval(&block)
        self.class.clean_room.new(self).instance_eval(&block)
        self
      end
    end
  end
end
