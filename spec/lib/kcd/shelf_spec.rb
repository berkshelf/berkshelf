require 'spec_helper'

module KnifeCookbookDependencies
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

    describe '#exclude' do
      it "should split on :" do
        subject.exclude("foo:bar")
        subject.excluded_groups.should == [:foo, :bar]
      end

      it "should split on ," do
        subject.exclude("foo,bar")
        subject.excluded_groups.should == [:foo, :bar]
      end

      it "should take an Array" do
        subject.exclude(["foo","bar"])
        subject.excluded_groups.should == [:foo, :bar]
      end
    end

    describe '#cookbook_groups' do
      it "should return a hash of groups and associated cookbooks" do
        subject.shelve_cookbook "foobar", :group => ["foo", "bar"]
        subject.shelve_cookbook "baz", :group => "baz"
        subject.shelve_cookbook "quux", :group => "quux"
        subject.shelve_cookbook "baz2", :group => "baz"
        groups = subject.cookbook_groups
        groups.keys.size.should == 4
        groups[:foo].should == ["foobar"]
        groups[:bar].should == ["foobar"]
        groups[:baz].should == ["baz", "baz2"]
        groups[:quux].should == ["quux"]
      end
    end

    describe '#requested_cookbooks'do
      it "should properly exclude cookbooks in the excluded groups" do
        subject.shelve_cookbook "a1", :group => "a"
        subject.shelve_cookbook "a2", :group => "a"
        subject.shelve_cookbook "b1", :group => "b"
        subject.shelve_cookbook "b2", :group => "b"
        subject.shelve_cookbook "c1", :group => ["a","b"]
        subject.exclude "b"
        subject.requested_cookbooks.should == ["a1", "a2", "c1"]
      end
    end
  end
end
