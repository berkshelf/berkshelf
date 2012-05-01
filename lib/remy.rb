require 'remy/shelf'
require 'remy/cookbook'

module Remy
  class << self
    def shelf
      @shelf ||= Remy::Shelf.new
    end

    def clear_shelf!
      @shelf = nil
    end
  end
end
