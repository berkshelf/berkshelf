require 'spec_helper'

module Remy
  describe Shelf do
    describe '#get_cookbook' do
      it "should return nil if a cookbook doesn't exist on the shelf" do
        Shelf.new.get_cookbook('arbitrary').should be_nil
      end
      it "should return the cookbook if the cookbook exists on the shelf" do
        s = Shelf.new
        s.shelve_cookbook example_cookbook_from_path
        s.get_cookbook(example_cookbook_from_path.name).should_not be_nil
      end
    end

    describe "#shelve_cookbook" do
      subject { Shelf.new }
      it 'should store shelved cookbooks' do
        subject.shelve_cookbook 'acookbook'
        subject.cookbooks.collect(&:name).should include 'acookbook'
      end

      it 'should take version constraints' do
        subject.shelve_cookbook 'acookbook', '= 1.2.3'
        subject.cookbooks.last.version_constraints.should == [DepSelector::VersionConstraint.new('= 1.2.3')]
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
