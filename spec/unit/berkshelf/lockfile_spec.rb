require 'spec_helper'

describe Berkshelf::Lockfile do
  describe "without a lockfile in place already" do
    before do
      @old_dir = Dir.pwd
      Dir.chdir fixtures_path.join("lockfile_spec", "without_lock")
    end

    it "should be able to write a Berksfile.lock from a list of cookbooks" do
      resolver = Berkshelf::Resolver.new(Berkshelf.downloader, Berkshelf::CookbookSource.new('nginx', '= 0.101.0'))
      resolver.resolve

      Berkshelf::Lockfile.new(resolver.sources).write

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
