require 'spec_helper'

module Berkshelf
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
          file "Berksfile"
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
          file "Berksfile"
          file ".chefignore"
        }
      end
    end

    context "with a metadata entry in the Berksfile" do
      before do
        generator = subject.new([], :path => target_root, :metadata_entry => true)
        capture(:stdout) { generator.invoke_all }
      end

      specify do
        target_root.should have_structure {
          file "Berksfile" do
            contains "metadata"
          end
        }
      end
    end
  end
end
