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
        subject.shelve_cookbook 'mysql', "= 1.2.4"
        
        subject.resolve_dependencies.should == ({"mysql" => DepSelector::Version.new("1.2.4"), "openssl" => DepSelector::Version.new("1.0.0")})
        Cookbook.new('mysql').clean
        Cookbook.new('openssl').clean
      end
    end
  end
end
