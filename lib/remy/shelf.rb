module Remy
  class Shelf
    attr_accessor :cookbooks

    def initialize
      @cookbooks = []
    end
    
    def shelve_cookbook name
      @cookbooks << name
    end
  end
end
