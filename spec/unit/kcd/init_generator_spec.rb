require 'spec_helper'

module KnifeCookbookDependencies
  describe InitGenerator do
    subject { InitGenerator }

    let(:target_root) { tmp_path.join("some_cookbook") }

    context "with default options" do
      before do
        generator = subject.new([], :path => target_root)
        capture(:stdout) { generator.invoke_all }
      end

      specify do
        target_root.should have_structure {
          file "Cookbookfile"
          no_file ".chefignore"
        }
      end
    end

    context "with a .chefignore" do
      before do
        generator = subject.new([], :path => target_root, :chefignore => true)
        capture(:stdout) { generator.invoke_all }
      end

      specify do
        target_root.should have_structure {
          file "Cookbookfile"
          file ".chefignore"
        }
      end
    end

    context "with a metadata entry in the Cookbookfile" do
      before do
        generator = subject.new([], :path => target_root, :metadata_entry => true)
        capture(:stdout) { generator.invoke_all }
      end

      specify do
        target_root.should have_structure {
          file "Cookbookfile" do
            contains "metadata"
          end
        }
      end
    end
  end
end
