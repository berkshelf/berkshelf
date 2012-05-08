require 'spec_helper'

module Remy
  describe DependencyReader do
    after do
      Cookbook.new('mysql').clean
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
  end
end
