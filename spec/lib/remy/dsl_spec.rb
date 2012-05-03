require 'spec_helper'
require 'remy/dsl'

module Remy
  describe DSL do
    include DSL

    describe "#cookbook" do
      it 'should add the cookbooks to the shelf' do
        cookbook "ntp"
        cookbook "nginx"

        ['ntp', 'nginx'].each do |cookbook|
          Remy.shelf.cookbooks.collect(&:name).should include cookbook
        end
      end

      it 'should take version constraints' do
        cookbook 'ntp', '= 1.2.3'
        Remy.shelf.cookbooks.select {|c| c.name == 'ntp'}.first.version_constraint.should == DepSelector::VersionConstraint.new('= 1.2.3')
      end
    end
  end
end
