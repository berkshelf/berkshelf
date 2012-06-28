require 'spec_helper'

module Berkshelf
  describe CachedCookbook do
    describe "ClassMethods" do
      subject { CachedCookbook }

      describe "#from_store_path" do
        before(:each) do
          @cached_cb = subject.from_store_path(fixtures_path.join("cookbooks", "example_cookbook-0.5.0"))
        end

        it "returns an instance of CachedCookbook" do
          @cached_cb.should be_a(CachedCookbook)
        end

        it "sets a version number" do
          @cached_cb.version.should eql("0.5.0")
        end

        context "given a path that does not contain a cookbook" do
          it "returns nil" do
            subject.from_store_path(tmp_path).should be_nil
          end
        end

        context "given a path that does not match the CachedCookbook dirname format" do
          it "returns nil" do
            subject.from_store_path(fixtures_path.join("cookbooks", "example_cookbook")).should be_nil
          end
        end
      end

      describe "#checksum" do
        it "returns a checksum of the given filepath" do
          subject.checksum(fixtures_path.join("cookbooks", "example_cookbook-0.5.0", "README.md")).should eql("6e21094b7a920e374e7261f50e9c4eef")
        end

        context "given path does not exist" do
          it "raises an Errno::ENOENT error" do
            lambda {
              subject.checksum(fixtures_path.join("notexisting.file"))
            }.should raise_error(Errno::ENOENT)
          end
        end
      end
    end

    let(:cb_path) { fixtures_path.join("cookbooks", "nginx-0.100.5") }
    subject { CachedCookbook.from_store_path(cb_path) }

    describe "#checksums" do
      it "returns a Hash containing an entry for all matching cookbook files on disk" do
        subject.checksums.should have(11).items
      end

      it "has a checksum for each key" do
        subject.checksums.should have_key("fb1f925dcd5fc4ebf682c4442a21c619")
      end

      it "has a filepath for each value" do
        subject.checksums.should have_value(cb_path.join("recipes/default.rb").to_s)
      end
    end

    describe "#manifest" do
      it "returns a Mash with a key for each cookbook file category" do
        [
          :recipes,
          :definitions,
          :libraries,
          :attributes,
          :files,
          :templates,
          :resources,
          :providers,
          :root_files
        ].each do |category|
          subject.manifest.should have_key(category)
        end
      end
    end

    describe "#validate!" do
      it "returns true if the cookbook of the given name and version is valid" do
        @cb = CachedCookbook.from_store_path(fixtures_path.join("cookbooks", "example_cookbook-0.5.0"))

        @cb.validate!.should be_true
      end

      it "raises CookbookSyntaxError if the cookbook contains invalid ruby files" do
        @cb = CachedCookbook.from_store_path(fixtures_path.join("cookbooks", "invalid_ruby_files-1.0.0"))

        lambda {
          @cb.validate!
        }.should raise_error(CookbookSyntaxError)
      end

      it "raises CookbookSyntaxError if the cookbook contains invalid template files" do
        @cb = CachedCookbook.from_store_path(fixtures_path.join("cookbooks", "invalid_template_files-1.0.0"))

        lambda {
          @cb.validate!
        }.should raise_error(CookbookSyntaxError)
      end
    end

    describe "#file_metadata" do
      let(:file) { subject.path.join("files", "default", "mime.types") }

      before(:each) { @metadata = subject.file_metadata(:file, file) }

      it "has a 'path' key whose value is a relative path from the CachedCookbook's path" do
        @metadata.should have_key(:path)
        @metadata[:path].should be_relative_path
        @metadata[:path].should eql("files/default/mime.types")
      end

      it "has a 'name' key whose value is the basename of the target file" do
        @metadata.should have_key(:name)
        @metadata[:name].should eql("mime.types")
      end

      it "has a 'checksum' key whose value is the checksum of the target file" do
        @metadata.should have_key(:checksum)
        @metadata[:checksum].should eql("06e7eca1d6cb608e2e74fd1f8e059f34")
      end

      it "has a 'specificity' key" do
        @metadata.should have_key(:specificity)
      end

      context "given a 'template' or 'file' berksfile type" do
        let(:file) { subject.path.join("files", "ubuntu", "mime.types") }
        before(:each) { @metadata = subject.file_metadata(:files, file) }

        it "has a 'specificity' key whose value represents the specificity found in filepath" do
          @metadata[:specificity].should eql("ubuntu")
        end
      end

      context "given any berksfile type that is not a 'template' or 'file'" do
        let(:file) { subject.path.join("README.md") }
        before(:each) { @metadata = subject.file_metadata(:root, file) }

        it "has a 'specificity' key whose value is 'default'" do
          @metadata[:specificity].should eql("default")
        end
      end
    end

    describe "#to_hash" do
      before(:each) do
        @hash = subject.to_hash
      end

      let(:cookbook_name) { subject.cookbook_name }
      let(:cookbook_version) { subject.version }

      it "has a 'recipes' key with a value of an Array Hashes" do
        @hash.should have_key('recipes')
        @hash['recipes'].should be_a(Array)
        @hash['recipes'].each do |item|
          item.should be_a(Hash)
        end
      end

      it "has a 'name' key value pair in a Hash of the 'recipes' Array of Hashes" do
        @hash['recipes'].first.should have_key('name')
      end

      it "has a 'path' key value pair in a Hash of the 'recipes' Array of Hashes" do
        @hash['recipes'].first.should have_key('path')
      end

      it "has a 'checksum' key value pair in a Hash of the 'recipes' Array of Hashes" do
        @hash['recipes'].first.should have_key('checksum')
      end

      it "has a 'specificity' key value pair in a Hash of the 'recipes' Array of Hashes" do
        @hash['recipes'].first.should have_key('specificity')
      end

      it "has a 'definitions' key with a value of an Array Hashes" do
        @hash.should have_key('definitions')
        @hash['definitions'].should be_a(Array)
        @hash['definitions'].each do |item|
          item.should be_a(Hash)
        end
      end

      it "has a 'name' key value pair in a Hash of the 'definitions' Array of Hashes" do
        @hash['definitions'].first.should have_key('name')
      end

      it "has a 'path' key value pair in a Hash of the 'definitions' Array of Hashes" do
        @hash['definitions'].first.should have_key('path')
      end

      it "has a 'checksum' key value pair in a Hash of the 'definitions' Array of Hashes" do
        @hash['definitions'].first.should have_key('checksum')
      end

      it "has a 'specificity' key value pair in a Hash of the 'definitions' Array of Hashes" do
        @hash['definitions'].first.should have_key('specificity')
      end

      it "has a 'libraries' key with a value of an Array Hashes" do
        @hash.should have_key('libraries')
        @hash['libraries'].should be_a(Array)
        @hash['libraries'].each do |item|
          item.should be_a(Hash)
        end
      end

      it "has a 'name' key value pair in a Hash of the 'libraries' Array of Hashes" do
        @hash['libraries'].first.should have_key('name')
      end

      it "has a 'path' key value pair in a Hash of the 'libraries' Array of Hashes" do
        @hash['libraries'].first.should have_key('path')
      end

      it "has a 'checksum' key value pair in a Hash of the 'libraries' Array of Hashes" do
        @hash['libraries'].first.should have_key('checksum')
      end

      it "has a 'specificity' key value pair in a Hash of the 'libraries' Array of Hashes" do
        @hash['libraries'].first.should have_key('specificity')
      end

      it "has a 'attributes' key with a value of an Array Hashes" do
        @hash.should have_key('attributes')
        @hash['attributes'].should be_a(Array)
        @hash['attributes'].each do |item|
          item.should be_a(Hash)
        end
      end

      it "has a 'name' key value pair in a Hash of the 'attributes' Array of Hashes" do
        @hash['attributes'].first.should have_key('name')
      end

      it "has a 'path' key value pair in a Hash of the 'attributes' Array of Hashes" do
        @hash['attributes'].first.should have_key('path')
      end

      it "has a 'checksum' key value pair in a Hash of the 'attributes' Array of Hashes" do
        @hash['attributes'].first.should have_key('checksum')
      end

      it "has a 'specificity' key value pair in a Hash of the 'attributes' Array of Hashes" do
        @hash['attributes'].first.should have_key('specificity')
      end

      it "has a 'files' key with a value of an Array Hashes" do
        @hash.should have_key('files')
        @hash['files'].should be_a(Array)
        @hash['files'].each do |item|
          item.should be_a(Hash)
        end
      end

      it "has a 'name' key value pair in a Hash of the 'files' Array of Hashes" do
        @hash['files'].first.should have_key('name')
      end

      it "has a 'path' key value pair in a Hash of the 'files' Array of Hashes" do
        @hash['files'].first.should have_key('path')
      end

      it "has a 'checksum' key value pair in a Hash of the 'files' Array of Hashes" do
        @hash['files'].first.should have_key('checksum')
      end

      it "has a 'specificity' key value pair in a Hash of the 'files' Array of Hashes" do
        @hash['files'].first.should have_key('specificity')
      end

      it "has a 'templates' key with a value of an Array Hashes" do
        @hash.should have_key('templates')
        @hash['templates'].should be_a(Array)
        @hash['templates'].each do |item|
          item.should be_a(Hash)
        end
      end

      it "has a 'name' key value pair in a Hash of the 'templates' Array of Hashes" do
        @hash['templates'].first.should have_key('name')
      end

      it "has a 'path' key value pair in a Hash of the 'templates' Array of Hashes" do
        @hash['templates'].first.should have_key('path')
      end

      it "has a 'checksum' key value pair in a Hash of the 'templates' Array of Hashes" do
        @hash['templates'].first.should have_key('checksum')
      end

      it "has a 'specificity' key value pair in a Hash of the 'templates' Array of Hashes" do
        @hash['templates'].first.should have_key('specificity')
      end

      it "has a 'resources' key with a value of an Array Hashes" do
        @hash.should have_key('resources')
        @hash['resources'].should be_a(Array)
        @hash['resources'].each do |item|
          item.should be_a(Hash)
        end
      end

      it "has a 'name' key value pair in a Hash of the 'resources' Array of Hashes" do
        @hash['resources'].first.should have_key('name')
      end

      it "has a 'path' key value pair in a Hash of the 'resources' Array of Hashes" do
        @hash['resources'].first.should have_key('path')
      end

      it "has a 'checksum' key value pair in a Hash of the 'resources' Array of Hashes" do
        @hash['resources'].first.should have_key('checksum')
      end

      it "has a 'specificity' key value pair in a Hash of the 'resources' Array of Hashes" do
        @hash['resources'].first.should have_key('specificity')
      end

      it "has a 'providers' key with a value of an Array Hashes" do
        @hash.should have_key('providers')
        @hash['providers'].should be_a(Array)
        @hash['providers'].each do |item|
          item.should be_a(Hash)
        end
      end

      it "has a 'name' key value pair in a Hash of the 'providers' Array of Hashes" do
        @hash['providers'].first.should have_key('name')
      end

      it "has a 'path' key value pair in a Hash of the 'providers' Array of Hashes" do
        @hash['providers'].first.should have_key('path')
      end

      it "has a 'checksum' key value pair in a Hash of the 'providers' Array of Hashes" do
        @hash['providers'].first.should have_key('checksum')
      end

      it "has a 'specificity' key value pair in a Hash of the 'providers' Array of Hashes" do
        @hash['providers'].first.should have_key('specificity')
      end

      it "has a 'root_files' key with a value of an Array Hashes" do
        @hash.should have_key('root_files')
        @hash['root_files'].should be_a(Array)
        @hash['root_files'].each do |item|
          item.should be_a(Hash)
        end
      end

      it "has a 'name' key value pair in a Hash of the 'root_files' Array of Hashes" do
        @hash['root_files'].first.should have_key('name')
      end

      it "has a 'path' key value pair in a Hash of the 'root_files' Array of Hashes" do
        @hash['root_files'].first.should have_key('path')
      end

      it "has a 'checksum' key value pair in a Hash of the 'root_files' Array of Hashes" do
        @hash['root_files'].first.should have_key('checksum')
      end

      it "has a 'specificity' key value pair in a Hash of the 'root_files' Array of Hashes" do
        @hash['root_files'].first.should have_key('specificity')
      end

      it "has a 'cookbook_name' key with a String value" do
        @hash.should have_key('cookbook_name')
        @hash['cookbook_name'].should be_a(String)
      end

      it "has a 'metadata' key with a Cookbook::Metadata value" do
        @hash.should have_key('metadata')
        @hash['metadata'].should be_a(Chef::Cookbook::Metadata)
      end

      it "has a 'version' key with a String value" do
        @hash.should have_key('version')
        @hash['version'].should be_a(String)
      end

      it "has a 'name' key with a String value" do
        @hash.should have_key('name')
        @hash['name'].should be_a(String)
      end

      it "has a value containing the cookbook name and version separated by a dash for 'name'" do
        name, version = @hash['name'].split('-')

        name.should eql(cookbook_name)
        version.should eql(cookbook_version)
      end

      it "has a 'chef_type' key with 'cookbook_version' as the value" do
        @hash.should have_key('chef_type')
        @hash['chef_type'].should eql("cookbook_version")
      end
    end

    describe "#to_json" do
      before(:each) do
        @json = subject.to_json
      end

      it "has a 'json_class' key with 'Chef::CookbookVersion' as the value" do
        @json.should have_json_path('json_class')
        parse_json(@json)['json_class'].should eql("Chef::CookbookVersion")
      end
    end
  end
end
