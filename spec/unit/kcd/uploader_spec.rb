require 'spec_helper'

module KnifeCookbookDependencies
  describe Uploader do
    let(:cookbook_store) { double('cookbook_store') }
    let(:server_url) { "https://api.opscode.com/organizations/vialstudios" }

    subject { Uploader.new(cookbook_store, server_url) }

    describe "#upload" do
      let(:cookbook) { double('nginx', name: "nginx", version: "0.101.2") }

      context "when cookbook is downloaded (cached)" do
        before(:each) do
          cookbook_store.stub(:cookbook) { cookbook }
        end

        context "when cookbook is valid" do
          before(:each) do
            cookbook.should_receive(:validate!).and_return(true)
            cookbook.should_receive(:checksums).and_return("da97c94bb6acb2b7900cbf951654fea3"=>"/Users/reset/code/knife_cookbook_dependencies/spec/fixtures/cookbooks/example_cookbook-0.5.0/recipes/default.rb")
            subject.should_receive(:create_sandbox)
            subject.should_receive(:upload_checksums_to_sandbox)
            subject.should_receive(:commit_sandbox)
            subject.should_receive(:save_cookbook)
          end

          it "returns a successful TXResult" do
            subject.upload(cookbook.name, cookbook.version).should be_success
          end
        end

        context "when cookbook is not valid" do
          before(:each) { cookbook.should_receive(:validate!).and_raise(CookbookSyntaxError) }

          it "returns a failed TXResult" do
            subject.upload(cookbook.name, cookbook.version).should be_failed
          end
        end
      end

      context "when cookbook is not downloaded (cached)" do
        before(:each) do
          cookbook_store.stub(:cookbook) { nil }
        end

        it "returns a failed TXResult" do
          subject.upload(cookbook.name, cookbook.version)
        end
      end
    end

    describe "#upload!" do
      let(:cookbook) { double('nginx', name: "nginx", version: "0.101.2") }

      context "when cookbook is not downloaded (cached)" do
        before(:each) do
          cookbook_store.stub(:cookbook) { nil }
        end

        it "raises UploadFailure if upload was not successful" do        
          lambda {
            subject.upload!(cookbook.name, cookbook.version)
          }.should raise_error(UploadFailure)
        end
      end
    end
  end
end
