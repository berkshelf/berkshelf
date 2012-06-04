require 'spec_helper'
require 'kcd/dsl'

module KnifeCookbookDependencies
  describe DSL do
    include DSL

    describe "#cookbook" do
      it 'should add the cookbook sources to the shelf' do
        cookbook "ntp"
        cookbook "nginx"

        ['ntp', 'nginx'].each do |name|
          KCD.shelf.should have_source(name)
        end
      end

      it 'should take version constraints' do
        cookbook 'ntp', '= 1.2.3'

        KCD.shelf['ntp'].version_constraint.should == DepSelector::VersionConstraint.new('= 1.2.3')
      end

      it 'should take group' do
        cookbook 'nginx', :group => 'web'

        KCD.shelf['nginx'].groups.should == [:web]
      end
    end

    describe '#group' do
      it "should set the group on all cookbooks" do
        cookbooks = %w[hashbrowns mashed_potatoes bourbon]
        group "awesome" do
          cookbooks.each {|c| cookbook c}
        end

        cookbooks.each do |c|
          KCD.shelf[c].groups.should == [:awesome]
        end
      end

      it "should not set the group on cookbooks after the group" do
        cookbooks = %w[apple orange strawberry]
        group "fruit" do
          cookbooks.each {|c| cookbook c}
        end

        cookbook 'sesame_chicken'
        KCD.shelf['sesame_chicken'].groups.should == [:default]
      end
    end

    describe "#metadata" do
      before(:each) do
        Dir.chdir fixtures_path.join('cookbooks/example_cookbook') do
          metadata
        end
      end

      it "should add Cookbook found at CWD of Cookbookfile to shelf" do
        KnifeCookbookDependencies.shelf.should have_source('example_cookbook')
      end
    end
  end
end
