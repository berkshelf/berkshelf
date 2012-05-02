require 'spec_helper'

module Remy
  describe Cheffile do
    describe '::read' do
      it "should read the cheffile and build a dependency list" do
        described_class.read <<CHEFFILE
cookbook 'ntp'
cookbook 'mysql'
CHEFFILE

        ['ntp', 'mysql'].each do |dep|
          Remy.shelf.cookbooks.collect(&:name).should include dep
        end
      end
    end
  end
end
