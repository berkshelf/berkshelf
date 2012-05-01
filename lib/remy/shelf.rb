module Remy
  class Shelf
    attr_accessor :cookbooks

    def initialize
      @cookbooks = []
    end
    
    def shelve_cookbook name, version_constraint=nil
      @cookbooks << Cookbook.new(name, version_constraint)
    end
  end
end
