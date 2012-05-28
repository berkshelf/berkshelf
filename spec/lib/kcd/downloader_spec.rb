require 'spec_helper'

module KnifeCookbookDependencies
  describe Downloader do
    subject { Downloader.new(tmp_path) }
    let(:source) { CookbookSource::SiteLocation.new("http://localhost") }

    describe "#enqueue" do
      it "should add a source to the queue" do
        subject.enqueue(source)

        subject.queue.length.should be(1)
      end

      it "should not allow you to add an invalid source" do
        lambda {
          subject.enqueue("a string, not a source")
        }.should raise_error(ArgumentError)
      end
    end

    describe "#dequeue" do
      before(:each) { subject.enqueue(source) }

      it "should remove a source from the queue" do
        subject.dequeue(source)

        subject.queue.length.should be(0)
      end
    end

    describe "#download" do
      context "given there items in the queue" do
        before(:each) do
          subject.enqueue(CookbookSource::SiteLocation.new("https://raw.github.com/RiotGames/knife_cookbook_dependencies/master/knife_cookbook_dependencies.gemspec"))
          subject.enqueue(CookbookSource::SiteLocation.new("https://raw.github.com/RiotGames/knife_cookbook_dependencies/master/.gitignore"))
        end

        it "should download all items in the queue to the storage_path" do
          subject.download

          tmp_path.should have_structure {
            file "knife_cookbook_dependencies.gemspec"
            file ".gitignore"
          }
        end

        it "should remove each item from the queue after a successful download" do
          subject.download

          subject.queue.should be_empty
        end

        it "should not remove the item from the queue if the download failed"
      end
    end
  end
end
