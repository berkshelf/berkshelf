module Berkshelf
  # A CleanRoom is a self-contained evaluation class used to evaluate methods
  # in a scope. In the case of Berkshelf, this is used to ensure only exposed
  # DSL methods are called during instance evaluation of the Berksfile.
  #
  # @param [#public_instance_methods] scope
  #   the (typically) Module of methods to be evaluated
  # @param [Object] instance
  #   and instance of the class that you want to evaluate against
  # @param [#to_s] contents
  #   the contents to instance_eval in the given scope
  class CleanRoom
    def initialize(scope, instance, contents)
      @instance = instance

      scope.public_instance_methods(false).each do |m|
        define_singleton_method(m) do |*args, &block|
          @instance.send(m, *args, &block)
        end
      end

      instance_eval(contents.to_s)
    end

    # The result of the evaluation. Creating a new CleanRoom will return a
    # CleanRoom. Calling {result} on that CleanRoom will return the instance
    # that was given in the initializer with the contents evaluated safely.
    #
    # @return [Object]
    #   the evaluated instance from {initialize}
    def result
      @instance
    end
  end
end
