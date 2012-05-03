require 'spec_helper'

module Remy
  describe Cookbookfile do
    describe '::read' do
      after do
        Remy.shelf.cookbooks.each(&:clean)
      end

      it "should read the cookbookfile and build a dependency list" do
        described_class.read <<COOKBOOKFILE
cookbook 'ntp', '<= 1.0.0'
cookbook 'mysql'
cookbook 'nginx', '< 0.101.2'
COOKBOOKFILE

        ['ntp', 'mysql'].each do |dep|
          Remy.shelf.cookbooks.collect(&:name).should include dep
        end

        Remy.shelf.populate_cookbooks_directory
      end
    end
  end
end
