require 'spec_helper'

module KnifeCookbookDependencies
  describe Downloader do
    subject { Downloader.new(tmp_path) }
    let(:source) { CookbookSource.new("sparkle_motion") }

    describe "#enqueue" do
      it "should add a source to the queue" do
        subject.enqueue(source)

        subject.queue.should have(1).thing
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

    describe "#download" do
      let(:cookbook_source_one) { CookbookSource.new("nginx", "0.101.2") }
      let(:cookbook_source_two) { CookbookSource.new("mysql", "1.2.6") }

      before(:each) do
        subject.enqueue(cookbook_source_one)
        subject.enqueue(cookbook_source_two)
      end

      it "should download all items in the queue to the storage_path" do
        subject.download

        tmp_path.should have_structure {
          file "nginx-0.101.2.tar.gz"
          file "mysql-1.2.6.tar.gz"
        }
      end

      it "should remove each item from the queue after a successful download" do
        subject.download

        subject.queue.should be_empty
      end

      it "should not remove the item from the queue if the download failed" do
        subject.enqueue(CookbookSource.new("bad_source", :site => "http://localhost/api"))
        subject.download

        subject.queue.should have(1).source
      end

      it "should return an array of CookbookSource instances" do
        results = subject.download

        results.each do |source|
          source.should be_a(CookbookSource)
        end
      end
    end
  end
end
