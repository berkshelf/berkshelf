require 'spec_helper'

module Remy
  describe DependencyReader do
    it "should parse the metadata file for dependencies" do
      cookbook = Cookbook.new('mysql')
      cookbook.download # TODO: mock out
      cookbook.unpack
      described_class.read(cookbook).should == [Cookbook.new('openssl')]
    end
  end
end
