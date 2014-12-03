require 'spec_helper'

describe Berkshelf::CookbookGenerator do
  let(:name)             { 'sparkle_motion' }
  let(:license)          { 'reserved' }
  let(:maintainer)       { 'Berkshelf Core' }
  let(:maintainer_email) { 'core@berkshelf.com' }

  let(:target) { tmp_path.join(name) }
  let(:kitchen_generator) { double('kitchen-generator', invoke_all: nil) }

  before do
    allow(Kitchen::Generator::Init)
      .to receive(:new)
      .with(any_args())
      .and_return(kitchen_generator)
  end

  context 'with default options' do
    before do
      capture(:stdout) do
        Berkshelf::CookbookGenerator.new([target, name],
          license:          license,
          maintainer:       maintainer,
          maintainer_email: maintainer_email,
        ).invoke_all
      end
    end

    it "generates a new cookbook" do
      expect(target).to have_structure {
        directory 'attributes'
        directory 'files' do
          directory 'default'
        end
        directory 'libraries'
        directory 'providers'
        directory 'recipes' do
          file 'default.rb' do
            contains '# Cookbook Name:: sparkle_motion'
            contains '# Recipe:: default'
            contains "# Copyright (C) #{Time.now.year} Berkshelf Core"
            contains '# All rights reserved - Do Not Redistribute'
          end
        end
        directory 'resources'
        directory 'templates' do
          directory 'default'
        end
        file 'LICENSE' do
          contains "Copyright (C) #{Time.now.year} Berkshelf Core"
          contains 'All rights reserved - Do Not Redistribute'
        end
        file 'README.md' do
          contains '# sparkle_motion-cookbook'
          contains '### sparkle_motion::default'
          contains "    <td><tt>['sparkle_motion']['bacon']</tt></td>"
          contains "Include `sparkle_motion` in your node's `run_list`:"
          contains '    "recipe[sparkle_motion::default]"'
          contains 'Author:: Berkshelf Core (<core@berkshelf.com>)'
        end
        file 'CHANGELOG.md' do
          contains '# 0.1.0'
          contains "Initial release of sparkle_motion"
        end
        file 'metadata.rb' do
          contains "name             'sparkle_motion'"
          contains "maintainer       'Berkshelf Core'"
          contains "maintainer_email 'core@berkshelf.com'"
          contains "license          'All rights reserved'"
          contains "description      'Installs/Configures sparkle_motion'"
        end
        file 'Berksfile' do
          contains 'source "https://supermarket.chef.io"'
          contains 'metadata'
        end
        file 'Gemfile'
        file 'chefignore'
      }
    end
  end

  context "given a 'maintainer_email' option" do
    before do
      allow(Kitchen::Generator::Init).to receive(:new).with(any_args()).and_return(kitchen_generator)
      capture(:stdout) {
        Berkshelf::CookbookGenerator.new([target, name], maintainer_email: 'jamie@vialstudios.com').invoke_all
      }
    end

    it "generates a metadata.rb with the 'maintainer_email' value set" do
      email = email
      expect(target).to have_structure {
        file 'metadata.rb' do
          contains "maintainer_email 'jamie@vialstudios.com'"
        end
      }
    end
  end

  context "given an invalid option for :license" do
    subject(:run) do
      capture(:stdout) { described_class.new([target, name], license: 'not-there').invoke_all }
    end

    it "raises a LicenseNotFound error" do
      expect { run }.to raise_error(Berkshelf::LicenseNotFound)
    end
  end
end
