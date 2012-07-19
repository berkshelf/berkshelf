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
            file "default.rb" do
              contains "# Cookbook Name:: sparkle_motion"
              contains "# Recipe:: default"
              contains "# Copyright (C) #{Time.now.year} YOUR_NAME"
              contains "# All rights reserved - Do Not Redistribute"
            end
          end
          directory "resources"
          directory "templates" do
            directory "default"
          end
          file "LICENSE" do
            contains "Copyright (C) #{Time.now.year} YOUR_NAME"
            contains "All rights reserved - Do Not Redistribute"
          end
          file "README.md" do
            contains "# sparkle_motion cookbook"
            contains "Author:: YOUR_NAME (<YOUR_EMAIL>)"
          end
          file "metadata.rb" do
            contains "name             \"sparkle_motion\""
            contains "maintainer       \"YOUR_NAME\""
            contains "maintainer_email \"YOUR_EMAIL\""
            contains "license          \"All rights reserved\""
            contains "description      \"Installs/Configures sparkle_motion\""
          end
          file "Berksfile" do
            contains "metadata"
          end
          file "Gemfile"
          file "chefignore"
        }
      end
    end

    context "given a value for the maintainer_email option" do
      before do
        @email = "jamie@vialstudios.com"
        generator = subject.new([name, target], maintainer_email: @email)
        capture(:stdout) { generator.invoke_all }
      end

      it "generates a metadata.rb with a default value for maintainer_email" do
        email = @email

        target.should have_structure {
          file "metadata.rb" do
            contains "maintainer_email \"#{email}\""
          end
        }
      end
    end
  end
end
