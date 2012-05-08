require 'spec_helper'
require 'knife_cookbook_dependencies/dsl'

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
        cookbook 'ntp', '= 1.2.3'
        KnifeCookbookDependencies.shelf.cookbooks.select {|c| c.name == 'ntp'}.first.version_constraint.should == DepSelector::VersionConstraint.new('= 1.2.3')
      end
    end
  end
end
