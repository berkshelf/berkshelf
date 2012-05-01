require 'remy/shelf'

module Remy
  class << self
    def shelf
      @shelf ||= Remy::Shelf.new
    end
  end
end
