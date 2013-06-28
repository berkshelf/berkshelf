require 'spec_helper'

describe Berkshelf::DSL, focus: true do
  subject { Class.new { include Berkshelf::DSL }.new }

  describe '#cookbook' do
    let(:name) { 'artifact' }
    let(:constraint) { double('constraint') }
    let(:default_options) { { group: [] } }

    it 'sends the add_dependency message with the name, constraint, and options to the instance of the includer' do
      subject.should_receive(:add_dependency).with(name, constraint, default_options)
      subject.cookbook(name, constraint, default_options)
    end

    it 'merges the default options into specified options' do
      subject.should_receive(:add_dependency).with(name, constraint, path: '/Users/reset', group: [])
      subject.cookbook(name, constraint, path: '/Users/reset')
    end

    it 'converts a single specified group option into an array of groups' do
      subject.should_receive(:add_dependency).with(name, constraint, group: [:production])
      subject.cookbook(name, constraint, group: :production)
    end

    context 'when no constraint specified' do
      it 'sends the add_dependency message with a nil value for constraint' do
        subject.should_receive(:add_dependency).with(name, nil, default_options)
        subject.cookbook(name, default_options)
      end
    end

    context 'when no options specified' do
      it 'sends the add_dependency message with an empty Hash for the value of options' do
        subject.should_receive(:add_dependency).with(name, constraint, default_options)
        subject.cookbook(name, constraint)
      end
    end
  end

  describe '#group' do
    it 'sends the add_dependency message with an array of groups determined by the parameter passed to the group block' do
      subject.should_receive(:add_dependency).with('artifact', nil, group: ['production'])

      subject.group('production') do
        cookbook('artifact')
      end
    end
  end

  describe '#metadata' do
    let(:path) { fixtures_path.join('cookbooks/example_cookbook') }
    subject { Berkshelf::Berksfile.new(path.join('Berksfile')) }

    before { Dir.chdir(path) }

    it 'sends the add_dependency message with an explicit version constraint and the path to the cookbook' do
      subject.should_receive(:add_dependency).with('example_cookbook', nil, path: path.to_s, metadata: true)
      subject.metadata
    end
  end

  describe '#site' do
    let(:uri) { 'http://opscode/v1' }

    it 'sends the add_location to the instance of the implementing class with a SiteLocation' do
      subject.should_receive(:add_location).with(:site, uri)
      subject.site(uri)
    end

    context 'given the symbol :opscode' do
      it 'sends an add_location message with the default Opscode Community API as the first parameter' do
        subject.should_receive(:add_location).with(:site, :opscode)
        subject.site(:opscode)
      end
    end
  end

  describe '#chef_api' do
    let(:uri) { 'http://chef:8080/' }

    it 'sends and add_location message with the type :chef_api and the given URI' do
      subject.should_receive(:add_location).with(:chef_api, uri, {})
      subject.chef_api(uri)
    end

    it 'also sends any options passed' do
      options = { node_name: 'reset', client_key: '/Users/reset/.chef/reset.pem' }
      subject.should_receive(:add_location).with(:chef_api, uri, options)
      subject.chef_api(uri, options)
    end

    context 'given the symbol :config' do
      it 'sends an add_location message with the the type :chef_api and the URI :config' do
        subject.should_receive(:add_location).with(:chef_api, :config, {})
        subject.chef_api(:config)
      end
    end
  end
end
