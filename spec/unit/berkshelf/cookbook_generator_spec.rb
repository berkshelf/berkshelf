require 'spec_helper'

module Berkshelf
  describe CookbookGenerator do
    subject { CookbookGenerator }

    let(:name) { "sparkle_motion" }
    let(:target) { tmp_path.join(name) }

    context "with default options" do
      before do
        generator = subject.new([name, target])
        capture(:stdout) { generator.invoke_all }
      end

      specify do
        target.should have_structure {
          directory "attributes"
          directory "definitions"
          directory "files" do
            directory "default"
          end
          directory "libraries"
          directory "providers"
          directory "recipes" do
            file "default.rb"
          end
          directory "resources"
          directory "templates" do
            directory "default"
          end
          file "README.md"
          file "metadata.rb"
          file "Berksfile" do
            contains "metadata"
          end
          file "chefignore"
        }
      end
    end
  end
end
