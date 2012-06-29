require 'spec_helper'

module Berkshelf
  describe Uploader do
    subject { Uploader.new(Chef::Config[:chef_server_url], client_key: Chef::Config[:client_key], node_name: Chef::Config[:node_name]) }

    describe "#upload" do
      let(:cookbook) { double('nginx', name: "nginx-0.101.2", cookbook_name: "nginx", version: "0.101.2") }

      context "when cookbook is valid" do
        before(:each) do
          cookbook.should_receive(:validate!).and_return(true)
          cookbook.should_receive(:checksums).and_return(
            "da97c94bb6acb2b7900cbf951654fea3" => 
              File.expand_path("spec/fixtures/cookbooks/example_cookbook-0.5.0/recipes/default.rb")
          )
          subject.should_receive(:create_sandbox)
          subject.should_receive(:upload_checksums_to_sandbox)
          subject.should_receive(:commit_sandbox)
          subject.should_receive(:save_cookbook)
        end

        it "returns a successful TXResult" do
          subject.upload(cookbook).should be_success
        end
      end

      context "when cookbook is not valid" do
        before(:each) { cookbook.should_receive(:validate!).and_raise(CookbookSyntaxError) }

        it "returns a failed TXResult" do
          subject.upload(cookbook).should be_failed
        end
      end
    end
  end
end
