require 'spec_helper'

module Remy
  describe Cookbook do
    subject { Cookbook.new('ntp') }

    before do
      Cookbook.any_instance.stub(:versions).and_return ['0.1.1', '0.9.0', '1.0.0', '1.1.8'].collect {|v| Gem::Version.new(v) }
      subject.clean
    end

    it "should raise an error if the cookbook is unpacked without being downloaded first" do
      -> { subject.unpack(false) }.should raise_error
    end

    describe '#unpacked_cookbook_path' do
      it "should give the path to the directory where the archive should get unpacked" do
        subject.unpacked_cookbook_path.should == '/tmp/ntp-1.1.8'
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
