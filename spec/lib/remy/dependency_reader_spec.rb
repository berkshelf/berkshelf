require 'spec_helper'

module Remy
  describe DependencyReader do
    subject { DependencyReader.new(Cookbook.new('mysql')) }

    before do
      @cookbook = Cookbook.new('mysql')
      @cookbook.download # TODO: mock out
      @cookbook.unpack
    end

    after do
      @cookbook.clean
    end

    it "should parse the metadata file for dependencies" do
      subject.read.should == [Cookbook.new('openssl')]
    end

    it "should not blow up when reading a metadata.rb that overrides the name" do
      Cookbook.any_instance.stub(:metadata_file).and_return <<M
name 'dontblowupplease'
version '1.2.3'
M
      -> { subject.read }.should_not raise_error
    end

    it 'should display a warning when no version is defined in the metadata.rb'

    it "should add a constraint to the cookbook on the shelf instead of adding a new dependency" do
      Remy.shelf.shelve_cookbook example_cookbook_from_path
      subject.depends('example_cookbook')
      subject.dependency_list.should be_empty
    end

    it "should create a new cookbook if the cookbook is not found on the shelf" do
      subject.depends('example_cookbook')
      subject.dependency_list.first.name.should == 'example_cookbook'
    end
  end
end
