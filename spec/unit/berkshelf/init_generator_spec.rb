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
          file "Gemfile" do
            contains "gem 'berkshelf'"
          end
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
        quietly { generator.invoke_all }
      end

      specify do
        target.should have_structure {
          file "Vagrantfile" do
            contains "recipe[some_cookbook::default]"
          end
          file "Gemfile" do
            contains "gem 'vagrant'"
          end
          directory "cookbooks"
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

    context "with the foodcritic option true" do
      before do
        generator = subject.new([target], foodcritic: true)
        capture(:stdout) { generator.invoke_all }
      end

      specify do
        target.should have_structure {
          file "Thorfile" do
            contains "require 'thor/foodcritic'"
          end
          file "Gemfile" do
            contains "gem 'thor-foodcritic'"
          end
        }
      end
    end

    context "with the scmversion option true" do
      before do
        generator = subject.new([target], scmversion: true)
        capture(:stdout) { generator.invoke_all }
      end

      specify do
        target.should have_structure {
          file "Thorfile" do
            contains "require 'thor/scmversion'"
          end
          file "Gemfile" do
            contains "gem 'thor-scmversion'"
          end
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

    context "given a value for the cookbook_name option" do
      it "sets the value of cookbook_name attribute to the specified option" do
        generator = subject.new([target], cookbook_name: "nautilus")

        generator.send(:cookbook_name).should eql("nautilus")
      end
    end

    context "when no value for cookbook_name option is specified" do
      it "infers the name of the cookbook from the directory name" do
        generator = subject.new([target])

        generator.send(:cookbook_name).should eql("some_cookbook")
      end
    end
  end
end
