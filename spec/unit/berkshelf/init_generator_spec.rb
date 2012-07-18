require 'spec_helper'

module Berkshelf
  describe InitGenerator do
    subject { InitGenerator }

    let(:target) { tmp_path.join("some_cookbook") }

    context "with default options" do
      before do
        generator = subject.new([target])
        capture(:stdout) { generator.invoke_all }
      end

      specify do
        target.should have_structure {
          file "Berksfile"
          file "Gemfile"
          no_file "chefignore"
        }
      end
    end

    context "with a chefignore" do
      before do
        generator = subject.new([target], chefignore: true)
        capture(:stdout) { generator.invoke_all }
      end

      specify do
        target.should have_structure {
          file "Berksfile"
          file "chefignore"
        }
      end
    end

    context "with a metadata entry in the Berksfile" do
      before do
        generator = subject.new([target], metadata_entry: true)
        capture(:stdout) { generator.invoke_all }
      end

      specify do
        target.should have_structure {
          file "Berksfile" do
            contains "metadata"
          end
        }
      end
    end

    context "with the vagrant option true" do
      before do
        generator = subject.new([target], vagrant: true)
        capture(:stdout) { generator.invoke_all }
      end

      specify do
        target.should have_structure {
          file "Vagrantfile"
        }
      end
    end

    context "with the git option true" do
      before do
        generator = subject.new([target], git: true)
        capture(:stdout) { generator.invoke_all }
      end

      specify do
        target.should have_structure {
          file ".gitignore"
        }
      end
    end

    context "with the thor option true" do
      before do
        generator = subject.new([target], thor: true)
        capture(:stdout) { generator.invoke_all }
      end

      specify do
        target.should have_structure {
          file "Thorfile"
        }
      end
    end

    context "with the bundler option true" do
      before do
        generator = subject.new([target], no_bundler: true)
        capture(:stdout) { generator.invoke_all }
      end

      specify do
        target.should have_structure {
          no_file "Gemfile"
        }
      end
    end
  end
end
