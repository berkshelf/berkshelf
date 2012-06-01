require 'spec_helper'

module KnifeCookbookDependencies
  describe Cookbookfile do
    describe "ClassMethods" do
      subject { Cookbookfile }

      let(:content) do
<<-EOF
cookbook 'ntp', '<= 1.0.0'
cookbook 'mysql'
cookbook 'nginx', '< 0.101.2'
cookbook 'ssh_known_hosts2', :git => 'https://github.com/erikh/chef-ssh_known_hosts2.git'
EOF
      end

      describe "#read" do
        it "reads the content of a Cookbookfile and adds the sources to the Shelf" do
          subject.read(content)
          ['ntp', 'mysql', 'nginx', 'ssh_known_hosts2'].each do |name|
            KCD.shelf.should have_source(name)
          end
        end

        it "returns an instance of Cookbookfile" do
          subject.read(content).should be_a(Cookbookfile)
        end
      end

      describe "#from_file" do
        let(:cookbook_file) { fixtures_path.join('lockfile_spec', 'with_lock', 'Cookbookfile') }

        it "reads a Cookbookfile and returns an instance Cookbookfile" do
          subject.from_file(cookbook_file).should be_a(Cookbookfile)
        end
      end
    end
  end
end
