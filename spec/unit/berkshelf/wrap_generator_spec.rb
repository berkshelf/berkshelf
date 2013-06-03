require 'spec_helper'

describe Berkshelf::WrapGenerator do
  let(:name) { 'sparkle_motion' }
  let(:target) { tmp_path.join(name) }
  let(:kitchen_generator) { double('kitchen-generator', invoke_all: nil) }

  before do
    Kitchen::Generator::Init.stub(:new).with(any_args()).and_return(kitchen_generator)
  end

  context 'with default options' do
    before do
      capture(:stdout) { Berkshelf::WrapGenerator.new([target, name]).invoke_all }
    end

    specify do
      expect(target).to have_structure {
        directory 'recipes' do
          file 'default.rb' do
            contains '# Cookbook Name:: chef-sparkle_motion'
            contains '# Recipe:: default'
            contains "# Copyright (C) #{Time.now.year} YOUR_NAME"
            contains '# All rights reserved - Do Not Redistribute'
          end
        end
        file 'LICENSE' do
          contains "Copyright (C) #{Time.now.year} YOUR_NAME"
          contains 'All rights reserved - Do Not Redistribute'
        end
        file 'README.md' do
          contains '# chef-sparkle_motion cookbook'
          contains 'Author:: YOUR_NAME (<YOUR_EMAIL>)'
        end
        file 'metadata.rb' do
          contains "name             'chef-sparkle_motion'"
          contains "maintainer       'YOUR_NAME'"
          contains "maintainer_email 'YOUR_EMAIL'"
          contains "license          'All rights reserved'"
          contains "description      'Wraps the sparkle_motion cookbook"
          contains "depends 'sparkle_motion'"
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
      Kitchen::Generator::Init.stub(:new).with(any_args()).and_return(kitchen_generator)
      capture(:stdout) {
        Berkshelf::WrapGenerator.new([target, name], maintainer_email: 'jamie@vialstudios.com').invoke_all
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
end
