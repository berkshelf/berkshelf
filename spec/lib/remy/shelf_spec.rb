require 'spec_helper'

module Remy
  describe Shelf do
    describe "#shelve_cookbook" do
      subject { Shelf.new }
      
      it 'should store shelved cookbooks' do
        subject.shelve_cookbook 'acookbook'
        subject.cookbooks.collect(&:name).should include 'acookbook'
      end

      it 'should take version constraints' do
        subject.shelve_cookbook 'acookbook', '= 1.2.3'
        subject.cookbooks.last.version_constraint.should == '= 1.2.3'
      end
    end
  end
end
