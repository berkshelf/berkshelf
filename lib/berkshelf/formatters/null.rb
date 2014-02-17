module Berkshelf
  class NullFormatter < BaseFormatter
    # The base formatter dynamically defines methods that raise an
    # AbstractFunction error. We need to define all of those on our class,
    # otherwise they will be inherited by the Ruby object model.
    BaseFormatter.instance_methods(false).each do |name|
      class_eval <<-EOH, __FILE__, __LINE__ + 1
        def #{name}(*args); end
      EOH
    end
  end
end
