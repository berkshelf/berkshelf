require 'spec_helper'

module Remy
  describe DependencyReader do
    after do
      Cookbook.new('mysql').clean
      DependencyReader.dependency_list.clear
    end

    it "should parse the metadata file for dependencies" do
      cookbook = Cookbook.new('mysql')
      cookbook.download # TODO: mock out
      cookbook.unpack
      described_class.read(cookbook).should == [Cookbook.new('openssl')]
    end

    it "should not blow up when reading a metadata.rb that overrides the name" do
      Cookbook.any_instance.stub(:metadata_file).and_return <<M
name 'dontblowupplease'
version '1.2.3'
M
      DependencyReader.read(example_cookbook_from_path)
    end

    it 'should display a warning when no version is defined in the metadata.rb'

    it "should read the shelf first before creating a new cookbook" do
      Remy.shelf.shelve_cookbook example_cookbook_from_path
      DependencyReader.depends('example_cookbook')
      DependencyReader.dependency_list.first.should be example_cookbook_from_path
    end

    it "should create a new cookbook if the cookbook is not found on the shelf" do
      DependencyReader.depends('example_cookbook')
      DependencyReader.dependency_list.first.name.should == 'example_cookbook'
    end
  end
end
