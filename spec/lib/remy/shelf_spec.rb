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
        subject.cookbooks.last.version_constraint.should == DepSelector::VersionConstraint.new('= 1.2.3')
      end

      it "should resolve the dependency graph of the cookbooks on the shelf" do
        subject.shelve_cookbook 'mysql'
        subject.resolve_dependencies.packages.keys.length.should == 3
        ['mysql', 'openssl', 'remy_shelf'].each do |package|
          subject.resolve_dependencies.packages[package].should_not be_nil
        end
      end
    end
  end
end
