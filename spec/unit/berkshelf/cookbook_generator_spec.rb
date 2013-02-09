require 'spec_helper'

describe Berkshelf::CookbookGenerator do
  subject { described_class }

  let(:name) { "sparkle_motion" }
  let(:target) { tmp_path.join(name) }

  context "with default options" do
    before do
      capture(:stdout) { subject.new([target, name]).invoke_all }
    end

    specify do
      expect(target).to have_structure {
        directory 'attributes'
        directory 'definitions'
        directory 'files' do
          directory 'default'
        end
        directory 'libraries'
        directory 'providers'
        directory 'recipes' do
          file 'default.rb' do
            contains '# Cookbook Name:: sparkle_motion'
            contains '# Recipe:: default'
            contains "# Copyright (C) #{Time.now.year} YOUR_NAME"
            contains '# All rights reserved - Do Not Redistribute'
          end
        end
        directory 'resources'
        directory 'templates' do
          directory 'default'
        end
        file 'LICENSE' do
          contains "Copyright (C) #{Time.now.year} YOUR_NAME"
          contains 'All rights reserved - Do Not Redistribute'
        end
        file 'README.md' do
          contains '# sparkle_motion cookbook'
          contains 'Author:: YOUR_NAME (<YOUR_EMAIL>)'
        end
        file 'metadata.rb' do
          contains 'name             "sparkle_motion"'
          contains 'maintainer       "YOUR_NAME"'
          contains 'maintainer_email "YOUR_EMAIL"'
          contains 'license          "All rights reserved"'
          contains 'description      "Installs/Configures sparkle_motion"'
        end
        file 'Berksfile' do
          contains 'site :opscode'
          contains 'metadata'
        end
        file 'Gemfile'
        file 'chefignore'
      }
    end
  end

  context "given a 'maintainer_email' option" do
    before do
      @email = "jamie@vialstudios.com"
      capture(:stdout) {
        described_class.new([target, name], maintainer_email: @email).invoke_all
      }
    end

    it "generates a metadata.rb with the 'maintainer_email' value set" do
      email = @email

      expect(target).to have_structure {
        file 'metadata.rb' do
          contains "maintainer_email \"#{email}\""
        end
      }
    end
  end
end
