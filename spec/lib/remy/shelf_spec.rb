require 'spec_helper'

module Remy
  describe Shelf do
    describe "#shelve_cookbook" do
      subject { Shelf.new }
      
      it 'should store shelved cookbooks' do
        subject.shelve_cookbook 'acookbook'
        subject.cookbooks.should include 'acookbook'
      end
    end
  end
end
