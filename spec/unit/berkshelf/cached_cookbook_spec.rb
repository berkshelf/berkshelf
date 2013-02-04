require 'spec_helper'

module Berkshelf
  describe CachedCookbook do
    describe "ClassMethods" do
      subject { CachedCookbook }

      describe "#from_path" do
        context "given a path that contains a cookbook with a metadata file that contains a name attribute" do
          let(:cookbook_path) { fixtures_path.join("cookbooks", "example_metadata_name") }

          it "returns an instance of CachedCookbook" do
            expect(subject.from_path(cookbook_path)).to be_a(CachedCookbook)
          end

          it "has a cookbook_name attribute set to what is found in the metadata" do
            expect(subject.from_path(cookbook_path).cookbook_name).to eql("has_metadata")
          end
        end

        context "given a path that contains a cookbook with a metadata file that does not contain a name attribute" do
          let(:cookbook_path) { fixtures_path.join("cookbooks", "example_metadata_no_name") }

          it "returns an instnace of CachedCookbook" do
            expect(subject.from_path(cookbook_path)).to be_a(CachedCookbook)
          end

          it "has a cookbook_name attribute set to the basename of the folder" do
            expect(subject.from_path(cookbook_path).cookbook_name).to eql("example_metadata_no_name")
          end

          it "sets value of metadata.name to the cookbook_name" do
            subject.from_path(cookbook_path).metadata.name.should eql("example_metadata_no_name")
          end
        end

        context "given a path that does not contain a metadata file" do
          let(:cookbook_path) { fixtures_path.join("cookbooks", "example_no_metadata") }

          it "raises a CookbookNotFound error" do
            expect {
              subject.from_path(cookbook_path)
            }.to raise_error(Berkshelf::CookbookNotFound)
          end
        end
      end

      describe "#from_store_path" do
        before(:each) do
          @cached_cb = subject.from_store_path(fixtures_path.join("cookbooks", "example_cookbook-0.5.0"))
        end

        it "returns an instance of CachedCookbook" do
          expect(@cached_cb).to be_a(CachedCookbook)
        end

        it "sets a version number" do
          expect(@cached_cb.version).to eql("0.5.0")
        end

        it "sets the metadata.name value to the cookbook_name" do
          @cached_cb.metadata.name.should eql("example_cookbook")
        end

        context "given a path that does not contain a cookbook" do
          it "returns nil" do
            expect(subject.from_store_path(tmp_path)).to be_nil
          end
        end

        context "given a path that does not match the CachedCookbook dirname format" do
          it "returns nil" do
            expect(subject.from_store_path(fixtures_path.join("cookbooks", "example_cookbook"))).to be_nil
          end
        end
      end

      describe "#checksum" do
        it "returns a checksum of the given filepath" do
          expect(subject.checksum(fixtures_path.join("cookbooks", "example_cookbook-0.5.0", "README.md"))).to eql("6e21094b7a920e374e7261f50e9c4eef")
        end

        context "given path does not exist" do
          it "raises an Errno::ENOENT error" do
            expect {
              subject.checksum(fixtures_path.join("notexisting.file"))
            }.to raise_error(Errno::ENOENT)
          end
        end
      end
    end

    let(:cb_path) { fixtures_path.join("cookbooks", "nginx-0.100.5") }
    subject { CachedCookbook.from_store_path(cb_path) }

    describe "#checksums" do
      it "returns a Hash containing an entry for all matching cookbook files on disk" do
        expect(subject.checksums).to have(11).items
      end

      it "has a checksum for each key" do
        expect(subject.checksums).to have_key("fb1f925dcd5fc4ebf682c4442a21c619")
      end

      it "has a filepath for each value" do
        expect(subject.checksums).to have_value(cb_path.join("recipes/default.rb").to_s)
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
          expect(subject.manifest).to have_key(category)
        end
      end
    end

    describe "#validate!" do
      let(:syntax_checker) { double('syntax_checker') }

      before(:each) do
        subject.stub(:syntax_checker) { syntax_checker }
      end

      it "asks the syntax_checker to validate the ruby and template files of the cookbook" do
        syntax_checker.should_receive(:validate_ruby_files).and_return(true)
        syntax_checker.should_receive(:validate_templates).and_return(true)

        subject.validate!
      end

      it "raises CookbookSyntaxError if the cookbook contains invalid ruby files" do
        syntax_checker.should_receive(:validate_ruby_files).and_return(false)

        expect {
          subject.validate!
        }.to raise_error(CookbookSyntaxError)
      end

      it "raises CookbookSyntaxError if the cookbook contains invalid template files" do
        syntax_checker.should_receive(:validate_ruby_files).and_return(true)
        syntax_checker.should_receive(:validate_templates).and_return(false)

        expect {
          subject.validate!
        }.to raise_error(CookbookSyntaxError)
      end
    end

    describe "#file_metadata" do
      let(:file) { subject.path.join("files", "default", "mime.types") }

      before(:each) { @metadata = subject.file_metadata(:file, file) }

      it "has a 'path' key whose value is a relative path from the CachedCookbook's path" do
        expect(@metadata).to have_key(:path)
        expect(@metadata[:path]).to be_relative_path
        expect(@metadata[:path]).to eql("files/default/mime.types")
      end

      it "has a 'name' key whose value is the basename of the target file" do
        expect(@metadata).to have_key(:name)
        expect(@metadata[:name]).to eql("mime.types")
      end

      it "has a 'checksum' key whose value is the checksum of the target file" do
        expect(@metadata).to have_key(:checksum)
        expect(@metadata[:checksum]).to eql("06e7eca1d6cb608e2e74fd1f8e059f34")
      end

      it "has a 'specificity' key" do
        expect(@metadata).to have_key(:specificity)
      end

      context "given a 'template' or 'file' berksfile type" do
        let(:file) { subject.path.join("files", "ubuntu", "mime.types") }
        before(:each) { @metadata = subject.file_metadata(:files, file) }

        it "has a 'specificity' key whose value represents the specificity found in filepath" do
          expect(@metadata[:specificity]).to eql("ubuntu")
        end
      end

      context "given any berksfile type that is not a 'template' or 'file'" do
        let(:file) { subject.path.join("README.md") }
        before(:each) { @metadata = subject.file_metadata(:root, file) }

        it "has a 'specificity' key whose value is 'default'" do
          expect(@metadata[:specificity]).to eql("default")
        end
      end
    end

    describe "#to_hash" do
      let(:hash) { subject.to_hash }

      let(:cookbook_name) { subject.cookbook_name }
      let(:cookbook_version) { subject.version }

      it "has a 'recipes' key with a value of an Array Hashes" do
        expect(hash).to have_key('recipes')
        expect(hash['recipes']).to be_a(Array)
        hash['recipes'].each do |item|
          expect(item).to be_a(Hash)
        end
      end

      it "has a 'name' key value pair in a Hash of the 'recipes' Array of Hashes" do
        expect(hash['recipes'].first).to have_key('name')
      end

      it "has a 'path' key value pair in a Hash of the 'recipes' Array of Hashes" do
        expect(hash['recipes'].first).to have_key('path')
      end

      it "has a 'checksum' key value pair in a Hash of the 'recipes' Array of Hashes" do
        expect(hash['recipes'].first).to have_key('checksum')
      end

      it "has a 'specificity' key value pair in a Hash of the 'recipes' Array of Hashes" do
        expect(hash['recipes'].first).to have_key('specificity')
      end

      it "has a 'definitions' key with a value of an Array Hashes" do
        expect(hash).to have_key('definitions')
        expect(hash['definitions']).to be_a(Array)
        hash['definitions'].each do |item|
          expect(item).to be_a(Hash)
        end
      end

      it "has a 'name' key value pair in a Hash of the 'definitions' Array of Hashes" do
        expect(hash['definitions'].first).to have_key('name')
      end

      it "has a 'path' key value pair in a Hash of the 'definitions' Array of Hashes" do
        expect(hash['definitions'].first).to have_key('path')
      end

      it "has a 'checksum' key value pair in a Hash of the 'definitions' Array of Hashes" do
        expect(hash['definitions'].first).to have_key('checksum')
      end

      it "has a 'specificity' key value pair in a Hash of the 'definitions' Array of Hashes" do
        expect(hash['definitions'].first).to have_key('specificity')
      end

      it "has a 'libraries' key with a value of an Array Hashes" do
        expect(hash).to have_key('libraries')
        expect(hash['libraries']).to be_a(Array)
        hash['libraries'].each do |item|
          expect(item).to be_a(Hash)
        end
      end

      it "has a 'name' key value pair in a Hash of the 'libraries' Array of Hashes" do
        expect(hash['libraries'].first).to have_key('name')
      end

      it "has a 'path' key value pair in a Hash of the 'libraries' Array of Hashes" do
        expect(hash['libraries'].first).to have_key('path')
      end

      it "has a 'checksum' key value pair in a Hash of the 'libraries' Array of Hashes" do
        expect(hash['libraries'].first).to have_key('checksum')
      end

      it "has a 'specificity' key value pair in a Hash of the 'libraries' Array of Hashes" do
        expect(hash['libraries'].first).to have_key('specificity')
      end

      it "has a 'attributes' key with a value of an Array Hashes" do
        expect(hash).to have_key('attributes')
        expect(hash['attributes']).to be_a(Array)
        hash['attributes'].each do |item|
          expect(item).to be_a(Hash)
        end
      end

      it "has a 'name' key value pair in a Hash of the 'attributes' Array of Hashes" do
        expect(hash['attributes'].first).to have_key('name')
      end

      it "has a 'path' key value pair in a Hash of the 'attributes' Array of Hashes" do
        expect(hash['attributes'].first).to have_key('path')
      end

      it "has a 'checksum' key value pair in a Hash of the 'attributes' Array of Hashes" do
        expect(hash['attributes'].first).to have_key('checksum')
      end

      it "has a 'specificity' key value pair in a Hash of the 'attributes' Array of Hashes" do
        expect(hash['attributes'].first).to have_key('specificity')
      end

      it "has a 'files' key with a value of an Array Hashes" do
        expect(hash).to have_key('files')
        expect(hash['files']).to be_a(Array)
        hash['files'].each do |item|
          expect(item).to be_a(Hash)
        end
      end

      it "has a 'name' key value pair in a Hash of the 'files' Array of Hashes" do
        expect(hash['files'].first).to have_key('name')
      end

      it "has a 'path' key value pair in a Hash of the 'files' Array of Hashes" do
        expect(hash['files'].first).to have_key('path')
      end

      it "has a 'checksum' key value pair in a Hash of the 'files' Array of Hashes" do
        expect(hash['files'].first).to have_key('checksum')
      end

      it "has a 'specificity' key value pair in a Hash of the 'files' Array of Hashes" do
        expect(hash['files'].first).to have_key('specificity')
      end

      it "has a 'templates' key with a value of an Array Hashes" do
        expect(hash).to have_key('templates')
        expect(hash['templates']).to be_a(Array)
        hash['templates'].each do |item|
          expect(item).to be_a(Hash)
        end
      end

      it "has a 'name' key value pair in a Hash of the 'templates' Array of Hashes" do
        expect(hash['templates'].first).to have_key('name')
      end

      it "has a 'path' key value pair in a Hash of the 'templates' Array of Hashes" do
        expect(hash['templates'].first).to have_key('path')
      end

      it "has a 'checksum' key value pair in a Hash of the 'templates' Array of Hashes" do
        expect(hash['templates'].first).to have_key('checksum')
      end

      it "has a 'specificity' key value pair in a Hash of the 'templates' Array of Hashes" do
        expect(hash['templates'].first).to have_key('specificity')
      end

      it "has a 'resources' key with a value of an Array Hashes" do
        expect(hash).to have_key('resources')
        expect(hash['resources']).to be_a(Array)
        hash['resources'].each do |item|
          expect(item).to be_a(Hash)
        end
      end

      it "has a 'name' key value pair in a Hash of the 'resources' Array of Hashes" do
        expect(hash['resources'].first).to have_key('name')
      end

      it "has a 'path' key value pair in a Hash of the 'resources' Array of Hashes" do
        expect(hash['resources'].first).to have_key('path')
      end

      it "has a 'checksum' key value pair in a Hash of the 'resources' Array of Hashes" do
        expect(hash['resources'].first).to have_key('checksum')
      end

      it "has a 'specificity' key value pair in a Hash of the 'resources' Array of Hashes" do
        expect(hash['resources'].first).to have_key('specificity')
      end

      it "has a 'providers' key with a value of an Array Hashes" do
        expect(hash).to have_key('providers')
        expect(hash['providers']).to be_a(Array)
        hash['providers'].each do |item|
          expect(item).to be_a(Hash)
        end
      end

      it "has a 'name' key value pair in a Hash of the 'providers' Array of Hashes" do
        expect(hash['providers'].first).to have_key('name')
      end

      it "has a 'path' key value pair in a Hash of the 'providers' Array of Hashes" do
        expect(hash['providers'].first).to have_key('path')
      end

      it "has a 'checksum' key value pair in a Hash of the 'providers' Array of Hashes" do
        expect(hash['providers'].first).to have_key('checksum')
      end

      it "has a 'specificity' key value pair in a Hash of the 'providers' Array of Hashes" do
        expect(hash['providers'].first).to have_key('specificity')
      end

      it "has a 'root_files' key with a value of an Array Hashes" do
        expect(hash).to have_key('root_files')
        expect(hash['root_files']).to be_a(Array)
        hash['root_files'].each do |item|
          expect(item).to be_a(Hash)
        end
      end

      it "has a 'name' key value pair in a Hash of the 'root_files' Array of Hashes" do
        expect(hash['root_files'].first).to have_key('name')
      end

      it "has a 'path' key value pair in a Hash of the 'root_files' Array of Hashes" do
        expect(hash['root_files'].first).to have_key('path')
      end

      it "has a 'checksum' key value pair in a Hash of the 'root_files' Array of Hashes" do
        expect(hash['root_files'].first).to have_key('checksum')
      end

      it "has a 'specificity' key value pair in a Hash of the 'root_files' Array of Hashes" do
        expect(hash['root_files'].first).to have_key('specificity')
      end

      it "has a 'cookbook_name' key with a String value" do
        expect(hash).to have_key('cookbook_name')
        expect(hash['cookbook_name']).to be_a(String)
      end

      it "has a 'metadata' key with a Cookbook::Metadata value" do
        expect(hash).to have_key('metadata')
        expect(hash['metadata']).to be_a(Chef::Cookbook::Metadata)
      end

      it "has a 'version' key with a String value" do
        expect(hash).to have_key('version')
        expect(hash['version']).to be_a(String)
      end

      it "has a 'name' key with a String value" do
        expect(hash).to have_key('name')
        expect(hash['name']).to be_a(String)
      end

      it "has a value containing the cookbook name and version separated by a dash for 'name'" do
        name, version = hash['name'].split('-')

        expect(name).to eql(cookbook_name)
        expect(version).to eql(cookbook_version)
      end

      it "has a 'chef_type' key with 'cookbook_version' as the value" do
        expect(hash).to have_key('chef_type')
        expect(hash['chef_type']).to eql("cookbook_version")
      end
    end

    describe '#to_json' do
      let(:json) { JSON.parse(subject.to_json) }

      it "has a 'chef_type' key" do
        expect(json['chef_type']).to eq('cookbook_version')
      end

      it "has a 'name' key" do
        expect(json['name']).to eq('nginx-0.100.5')
      end

      it "has a 'cookbook_name' key" do
        expect(json['cookbook_name']).to eq('nginx')
      end

      it "has a 'version' key" do
        expect(json['version']).to eq('0.100.5')
      end

      it "has a 'metadata' key" do
        expect(json['metadata']).to_not be_nil
      end

      it "has a 'json_class' key" do
        expect(json['json_class']).to eq('Chef::CookbookVersion')
      end

      it "has a 'frozen?' key" do
        expect(json['frozen?']).to be_false
      end
    end

    describe "#dependencies" do
      let(:dependencies) { { "mysql" => "= 1.2.0", "ntp" => ">= 0.0.0" } }
      let(:recommendations) { { "database" => ">= 0.0.0" } }

      let(:cb_path) do
        generate_cookbook(Berkshelf.cookbook_store.storage_path, "sparkle", "0.1.0", dependencies: dependencies, recommendations: recommendations)
      end

      subject { CachedCookbook.from_store_path(cb_path) }

      it "contains depends from the cookbook metadata" do
        expect(subject.dependencies).to include(dependencies)
      end

      it "contains recommendations from the cookbook metadata" do
        expect(subject.dependencies).to include(recommendations)
      end
    end
  end
end
