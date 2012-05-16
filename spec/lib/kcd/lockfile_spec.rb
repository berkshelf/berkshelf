require 'spec_helper'

describe KCD::Lockfile do
  describe "without a lockfile in place already" do
    before do
      @old_dir = Dir.pwd
      Dir.chdir "spec/fixtures/lockfile_spec/without_lock"
      KCD.clear_shelf!
    end

    after do
      FileUtils.rm_r "cookbooks"
      Dir.chdir @old_dir
    end

    it "should be able to write a Cookbookfile.lock from a list of cookbooks" do
      KCD.shelf.shelve_cookbook('nginx', '= 0.101.0')
      KCD.shelf.resolve_dependencies
      KCD.shelf.populate_cookbooks_directory
      KCD.shelf.write_lockfile

      File.read('Cookbookfile.lock').split(/\r?\n/).sort.should == [
        "cookbook 'bluepill', :locked_version => '1.0.4'",
        "cookbook 'build-essential', :locked_version => '1.0.0'", 
        "cookbook 'nginx', :locked_version => '0.101.0'", 
        "cookbook 'ohai', :locked_version => '1.0.2'", 
        "cookbook 'runit', :locked_version => '0.15.0'"
      ] 
    end
  end

  describe "with a lockfile in place" do
    before do
      @old_dir = Dir.pwd
      Dir.chdir "spec/fixtures/lockfile_spec/with_lock"
      KCD::Cookbookfile.process_install
      KCD.clear_shelf!
    end

    after do
      FileUtils.rm_r "cookbooks"
      FileUtils.rm "Cookbookfile.lock"
      Dir.chdir @old_dir
    end

    it "should populate the cookbooks directory from the lockfile" do
      lockfile = File.read('Cookbookfile.lock')
      lockfile.gsub!(/0.101.0/, '0.101.2')
      File::open('Cookbookfile.lock', 'wb') { |f| f.write lockfile }
      KCD::Cookbookfile.process_install
      File.read('cookbooks/nginx/metadata.rb').scan(/version\s*"([^"]+)"/).first.first.should == "0.101.2"
    end
  end
end
