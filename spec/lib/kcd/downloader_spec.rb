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
      context "downloading a CookbookSource with no location key" do
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

        it "should mark the source as downloaded after a successful download" do
          subject.download

          cookbook_source_one.should be_downloaded
          cookbook_source_two.should be_downloaded
        end

        it "should write a value to local_path after a successful download" do
          subject.download

          cookbook_source_two.local_path.should_not be_nil
        end

        it "should not remove the item from the queue if the download failed" do
          subject.enqueue(CookbookSource.new("bad_source", :site => "http://localhost/api"))
          VCR.use_cassette('bad_source', :record => :new_episodes) do
            subject.download
          end

          subject.queue.should have(1).source
        end

        it "should return an array of CookbookSource instances" do
          results = subject.download

          results.each do |source|
            source.should be_a(CookbookSource)
          end
        end
      end

      context "downloading a CookbookSource with a :path location key" do
        before(:each) do
          subject.enqueue CookbookSource.new("sparkle_motion", :path => "/tmp/sparkle_motion")
        end

        it "should not dowload sources into the storage_path" do
          subject.download

          tmp_path.should_not have_structure {
            file "sparkle_motion-latest"
            directory "sparkle_motion-latest"
          }
        end

        it "should remove all sources from the queue after a successful download" do
          subject.download

          subject.queue.should be_empty
        end
      end

      context "downloading a CookbookSource with a :git location key" do
        before(:each) do
          subject.enqueue CookbookSource.new("nginx", :git => "https://github.com/erikh/chef-ssh_known_hosts2.git")
        end

        it "should download the source in the queue to the storage_path" do
          subject.download

          tmp_path.should have_structure {
            directory "nginx"
          }
        end

        it "should remove the sources from the queue after successful download" do
          subject.download

          subject.queue.should be_empty
        end
      end

      context "downloading a CookbookSource with a :site location key" do
        before(:each) do
          subject.enqueue CookbookSource.new("nginx", "0.101.2", :site => "http://cookbooks.opscode.com/api/v1/cookbooks")
        end

        it "should download the source in the queue to the storage_path" do
          subject.download

          tmp_path.should have_structure {
            file "nginx-0.101.2.tar.gz"
          }
        end

        it "should remove the sources from the queue after successful download" do
          subject.download

          subject.queue.should be_empty
        end
      end
    end
  end
end
