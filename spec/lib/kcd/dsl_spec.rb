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

      it 'should take group' do
        cookbook 'nginx', :group => 'web'
        KnifeCookbookDependencies.shelf.cookbooks.select {|c| c.name == 'nginx'}.first.groups.should == [:web]
      end
    end

    describe '#group' do
      it "should set the group on all cookbooks" do
        cookbooks = %w[hashbrowns mashed_potatoes bourbon]
        group "awesome" do
          cookbooks.each {|c| cookbook c}
        end
        cookbooks.each do |c|
          KnifeCookbookDependencies.shelf.cookbooks.select {|n| n.name == c}.first.groups.should == [:awesome]
        end
      end

      it "should not set the group on cookbooks after the group" do
        cookbooks = %w[apple orange strawberry]
        group "fruit" do
          cookbooks.each {|c| cookbook c}
        end
        cookbook 'sesame_chicken'
        KnifeCookbookDependencies.shelf.cookbooks.select {|n| n.name == 'sesame_chicken'}.first.groups.should == [:default]
      end

    end
  end
end
