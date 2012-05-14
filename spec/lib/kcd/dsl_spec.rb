require 'spec_helper'
require 'kcd/dsl'

module KnifeCookbookDependencies
  describe DSL do
    include DSL

    describe "#cookbook" do
      after do
        KnifeCookbookDependencies.shelf.cookbooks.each(&:clean)
      end

      it 'should add the cookbooks to the shelf' do
        cookbook "ntp"
        cookbook "nginx"

        ['ntp', 'nginx'].each do |cookbook|
          KnifeCookbookDependencies.shelf.cookbooks.collect(&:name).should include cookbook
        end
      end

      it 'should take version constraints' do
        Cookbook.any_instance.stub(:clean)
        cookbook 'ntp', '= 1.2.3'
        KnifeCookbookDependencies.shelf.cookbooks.select {|c| c.name == 'ntp'}.first.version_constraints.first.should == DepSelector::VersionConstraint.new('= 1.2.3')
      end
    end
  end
end
