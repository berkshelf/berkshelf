require 'spec_helper'

module KnifeCookbookDependencies
  describe Cookbook do
    subject { Cookbook.new('ntp') }

    after do
      subject.clean
    end

    describe do
      before do
        Cookbook.any_instance.stub(:versions).and_return ['0.1.1', '0.9.0', '1.0.0', '1.1.8'].collect {|v| Gem::Version.new(v) }
      end

      # FIXME: This test is flakey
      it "should raise an error if the cookbook is unpacked without being downloaded first" do
        -> { subject.unpack(subject.unpacked_cookbook_path, :clean => true, :download => false) }.should raise_error
      end

      describe '#unpacked_cookbook_path' do
        it "should give the path to the directory where the archive should get unpacked" do
          subject.unpacked_cookbook_path.should == File.join(ENV['TMPDIR'], 'ntp-1.1.8')
        end
      end

      it 'should treat cookbooks pulled from a path like a cookbook that has already been unpacked with the path as the unpacked location' do
        example_cookbook_from_path.unpacked_cookbook_path.should == File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "..", "spec", "fixtures", "cookbooks"))
      end

      it "should not attempt to download a cookbook being pulled from a path" do
        Chef::Knife::CookbookSiteDownload.any_instance.should_not_receive(:run)
        example_cookbook_from_path.download
      end

      describe "#copy_to" do
        it "should copy from the unpacked cookbook directory to the target" do
          example_cookbook_from_path.copy_to_cookbooks_directory
          File.exists?(File.join(KCD::COOKBOOKS_DIRECTORY, example_cookbook_from_path.name)).should be_true
        end
      end
    end

    describe "#versions" do
      it "should return the version in the metadata file as the available versions for a path sourced cookbook" do
        example_cookbook_from_path.versions.should == [DepSelector::Version.new('0.5.0')]
      end
    end

    describe '#version_from_metadata' do
      it "should return the correct version" do
        subject.version_from_metadata.should == DepSelector::Version.new('1.1.8')
      end
    end

    describe '#version_constraints_include?' do
      it "should cycle through all the version constraints to confirm that all of them are satisfied" do
        subject.add_version_constraint ">= 1.0.0"
        subject.add_version_constraint "< 2.0.0"
        subject.version_constraints_include?(DepSelector::Version.new('1.0.0')).should be_true
        subject.version_constraints_include?(DepSelector::Version.new('1.5.0')).should be_true
        subject.version_constraints_include?(DepSelector::Version.new('2.0.0')).should be_false
      end
    end

    describe '#add_version_constraint' do
      it "should not duplicate version constraints" do
        subject.add_version_constraint ">= 1.0.0"
        subject.add_version_constraint ">= 1.0.0"
        subject.add_version_constraint ">= 1.0.0"
        subject.add_version_constraint ">= 1.0.0"
        subject.version_constraints.size.should == 2 # 1 for the
                                                     # default when
                                                     # the cookbook
                                                     # was created in
                                                     # the subject
                                                     # instantiation
                                                     # line
      end
    end

    describe '#dependencies' do
      it "should not contain the cookbook itself" do
        # TODO: Mock
        Cookbook.new('nginx').dependencies.collect(&:name).include?('nginx').should_not be_true
      end

      it "should compute the correct dependencies" do
        cookbook = Cookbook.new('mysql')
        cookbook.dependencies.should == [Cookbook.new('openssl')]
      end
    end

    # TODO figure out how to test this. Stubs on classes don't clear after a test.
    # describe '#unpack' do
    #   it "should not unpack if it is already unpacked" do
    #     Archive::Tar::Minitar.should_receive(:unpack).once
    #     subject.unpack
    #     subject.unpack
    #   end
    # end

    describe '#groups' do
      it "should have the default group" do
        subject.groups.should == [:default]
      end
    end

    describe '#add_group' do
      it "should store strings as symbols" do
        subject.add_group "foo"
        subject.groups.should == [:default, :foo]
      end

      it "should not store duplicate groups" do
        subject.add_group "bar"
        subject.add_group "bar"
        subject.add_group :bar
        subject.groups.should == [:default, :bar]
      end

      it "should add multiple groups" do
        subject.add_group "baz", "quux"
        subject.groups.should == [:default, :baz, :quux]
      end

      it "should handle multiple groups as an array" do
        subject.add_group ["baz", "quux"]
        subject.groups.should == [:default, :baz, :quux]
      end
    end
  end
end
