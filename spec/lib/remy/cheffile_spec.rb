require 'spec_helper'

module Remy
  describe Cheffile do
    describe '::read' do
      after do
        Remy.shelf.cookbooks.each(&:clean)
      end

      it "should read the cheffile and build a dependency list" do
        described_class.read <<CHEFFILE
cookbook 'ntp', '<= 1.0.0'
cookbook 'mysql'
cookbook 'nginx', '< 0.101.2'
CHEFFILE

        ['ntp', 'mysql'].each do |dep|
          Remy.shelf.cookbooks.collect(&:name).should include dep
        end

        Remy.shelf.populate_cookbooks_directory
      end
    end
  end
end
