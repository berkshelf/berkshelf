require 'spec_helper'

module Berkshelf
  describe Uploader do
    subject { Uploader.new(server_url: Chef::Config[:chef_server_url], client_key: Chef::Config[:client_key], client_name: Chef::Config[:node_name]) }

    describe "#upload" do
      let(:cookbook) { double('nginx', name: "nginx-0.101.2", cookbook_name: "nginx", version: "0.101.2") }

      context "when cookbook is invalid" do
        before(:each) { cookbook.should_receive(:validate!).and_raise(CookbookSyntaxError) }

        it "raises a CookbookSyntaxError error" do
          lambda {
            subject.upload(cookbook)
          }.should raise_error(CookbookSyntaxError)
        end
      end
    end
  end
end
