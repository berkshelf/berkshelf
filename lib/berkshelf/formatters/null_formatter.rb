module Berkshelf
  class Formatters::NullFormatter < Formatter
    superclass.instance_methods(false).each do |meth|
      class_eval(<<-EOH, __FILE__, __LINE__ + 1)
        def #{meth}(*args); end
      EOH
    end
  end
end
