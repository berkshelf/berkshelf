require 'spec_helper'

module KnifeCookbookDependencies
  describe Cookbookfile do
    describe '::read' do
      after do
        KnifeCookbookDependencies.shelf.cookbooks.each(&:clean)
      end

      it "should read the cookbookfile and build a dependency list" do
        described_class.read <<COOKBOOKFILE
cookbook 'ntp', '<= 1.0.0'
cookbook 'mysql'
cookbook 'nginx', '< 0.101.2'
cookbook 'ssh_known_hosts2', :git => 'https://github.com/erikh/chef-ssh_known_hosts2.git'
COOKBOOKFILE

        ['ntp', 'mysql', 'nginx', 'ssh_known_hosts2'].each do |dep|
          KnifeCookbookDependencies.shelf.cookbooks.collect(&:name).should include dep
        end

        KnifeCookbookDependencies.shelf.populate_cookbooks_directory
      end
    end
  end
end
