require 'spec_helper'

module KnifeCookbookDependencies
  describe Downloader do
    subject { Downloader.new(tmp_path) }
    let(:source) { CookbookSource.new("sparkle_motion") }

    describe "#enqueue" do
      it "should add a source to the queue" do
        subject.enqueue(source)

        subject.queue.should have(1).source
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

        subject.queue.should be_empty
      end
    end

    describe "#download_all" do
      let(:source_one) { CookbookSource.new("nginx") }
      let(:source_two) { CookbookSource.new("mysql") }

      before(:each) do
        subject.enqueue source_one
        subject.enqueue source_two
      end

      it "should remove each item from the queue after a successful download" do
        subject.download_all

        subject.queue.should be_empty
      end

      it "should not remove the item from the queue if the download failed" do
        subject.enqueue CookbookSource.new("does_not_exist_no_way")
        subject.download_all

        subject.queue.should have(1).sources
      end

      it "should return a ResultSet" do
        results = subject.download_all

        results.should be_a(Downloader::ResultSet)
      end
    end
  end
end
