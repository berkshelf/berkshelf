require 'spec_helper'
require 'berkshelf/dsl'

module Berkshelf
  describe DSL do
    subject do
      Class.new do
        include Berkshelf::DSL
      end.new
    end

    describe "#cookbook" do
      it "calls add source to the instance of the implementing class with a CookbookSource" do
        subject.should_receive(:add_source).with(kind_of(CookbookSource))
        
        subject.cookbook "ntp"
      end
    end

    describe '#group' do
      it "calls add source to the instance of the implementing class with a CookbookSource" do
        subject.should_receive(:add_source).with(kind_of(CookbookSource))
        
        subject.group "awesome" do
          subject.cookbook "ntp"
        end
      end
    end

    describe "#metadata" do
      before(:each) do
        Dir.chdir fixtures_path.join('cookbooks/example_cookbook')
      end

      it "calls add source to the instance of the implementing class with a CookbookSource" do
        subject.should_receive(:add_source).with(kind_of(CookbookSource))
        
        subject.metadata
      end
    end
  end
end
