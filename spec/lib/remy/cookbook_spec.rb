require 'spec_helper'

module Remy
  describe Cookbook do
    subject { Cookbook.new('ntp') }

    after do
      subject.clean
    end

    describe  do

      before do
        Cookbook.any_instance.stub(:versions).and_return ['0.1.1', '0.9.0', '1.0.0', '1.1.8'].collect {|v| Gem::Version.new(v) }
      end

      it "should raise an error if the cookbook is unpacked without being downloaded first" do
        -> { subject.unpack(subject.unpacked_cookbook_path, true, false) }.should raise_error
      end

      describe '#unpacked_cookbook_path' do
        it "should give the path to the directory where the archive should get unpacked" do
          subject.unpacked_cookbook_path.should == File.join(ENV['TMPDIR'], 'ntp-1.1.8')
        end
      end

      it 'should treat cookbooks pulled from a path like a cookbook that has already been unpacked with the path as the unpacked location' do
        c = Cookbook.new 'test', path: '/a/path'
        c.unpacked_cookbook_path.should == '/a/path'
      end

      it "should not attempt to download a cookbook being pulled from a path" do
        Chef::Knife::CookbookSiteDownload.any_instance.should_not_receive(:run)
        example_cookbook_from_path.download
      end

      describe "#copy_to" do
        it "should copy from the unpacked cookbook directory to the target" do
          example_cookbook_from_path.copy_to_cookbooks_directory
          File.exists?(File.join(Remy::COOKBOOKS_DIRECTORY, example_cookbook_from_path.name)).should be_true
        end
      end
      
    end

    describe "#versions" do
      it "should return the version in the metadata file as the available versions for a path sourced cookbook" do
        example_cookbook_from_path.versions.should == [DepSelector::Version.new('0.5.0')]
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
  end
end
