require 'spec_helper'

module Berkshelf
  describe Lockfile do
    let(:downloader) { Downloader.new(Berkshelf.cookbook_store) }
    
    describe "without a lockfile in place already" do
      before(:all) do
        @old_dir = Dir.pwd
        Dir.chdir fixtures_path.join("lockfile_spec", "without_lock")
      end

      after(:all) do
        FileUtils.rm(fixtures_path.join("lockfile_spec", "without_lock", "Berksfile.lock"))
        Dir.chdir(@old_dir)
      end

      it "should be able to write a Berksfile.lock from a list of cookbooks" do
        resolver = Resolver.new(downloader, sources: CookbookSource.new('nginx', constraint: '= 0.101.0'))
        resolver.resolve

        Lockfile.new(resolver.sources).write

        File.read('Berksfile.lock').split(/\r?\n/).sort.should == [
          "cookbook 'bluepill', :locked_version => '1.0.4'",
          "cookbook 'build-essential', :locked_version => '1.0.2'",
          "cookbook 'nginx', :locked_version => '0.101.0'",
          "cookbook 'ohai', :locked_version => '1.0.2'",
          "cookbook 'runit', :locked_version => '0.15.0'"
        ]
      end
    end
  end
end
