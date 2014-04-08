require 'spec_helper'

module Berkshelf
  describe Uploader do
    let(:berksfile) do
      double(Berksfile,
        lockfile: lockfile,
        dependencies: [],
      )
    end

    let(:lockfile) do
      double(Lockfile,
        graph: graph
      )
    end

    let(:graph) { double(Lockfile::Graph, locks: {}) }

    subject { Uploader.new(berksfile) }

    describe '#initialize' do
      it 'saves the berksfile' do
        instance = Uploader.new(berksfile)
        expect(instance.berksfile).to be(berksfile)
      end

      it 'saves the lockfile' do
        instance = Uploader.new(berksfile)
        expect(instance.lockfile).to be(lockfile)
      end

      it 'saves the options' do
        instance = Uploader.new(berksfile, force: true, validate: false)
        options = instance.options
        expect(options[:force]).to be_true
        expect(options[:validate]).to be_false
      end

      it 'saves the names' do
        instance = Uploader.new(berksfile, 'cookbook_1', 'cookbook_2')
        expect(instance.names).to eq(['cookbook_1', 'cookbook_2'])
      end
    end

    describe '#validate_files!' do
      before { Uploader.send(:public, :validate_files!) }

      let(:cookbook) { double('cookbook', cookbook_name: 'cookbook', path: 'path') }

      it 'raises an error when the cookbook has spaces in the files' do
        Dir.stub(:glob).and_return(['/there are/spaces/in this/recipes/default.rb'])
        expect {
          subject.validate_files!(cookbook)
        }.to raise_error
      end

      it 'does not raise an error when the cookbook is valid' do
        Dir.stub(:glob).and_return(['/there-are/no-spaces/in-this/recipes/default.rb'])
        expect {
          subject.validate_files!(cookbook)
        }.to_not raise_error
      end

      it 'does not raise an exception with spaces in the path' do
        Dir.stub(:glob).and_return(['/there are/spaces/in this/recipes/default.rb'])
        Pathname.any_instance.stub(:dirname).and_return('/there are/spaces/in this')

        expect {
          subject.validate_files!(cookbook)
        }.to_not raise_error
      end
    end

    describe '#run' do
      let(:options) { Hash.new }

      let(:chef_config) do
        double(Ridley::Chef::Config,
          node_name: 'fake-client',
          client_key: 'client-key',
          chef_server_url: 'http://configured-chef-server/',
          validation_client_name: 'validator',
          validation_key: 'validator.pem',
          cookbook_copyright: 'user',
          cookbook_email: 'user@example.com',
          cookbook_license: 'apachev2',
        )
      end

      let(:berkshelf_config) do
        double(Config,
          ssl:  double(verify: true),
          chef: chef_config,
        )
      end

      let(:default_ridley_options) do
        {
          client_name: 'fake-client',
          client_key: 'client-key',
          ssl: {
            verify: true
          }
        }
      end

      before do
        Berkshelf.stub(:config).and_return(berkshelf_config)
      end

      context 'when there is no value for :chef_server_url' do
        before { chef_config.stub(chef_server_url: nil) }
        let(:message) { 'Missing required attribute in your Berkshelf configuration: chef.server_url' }

        it 'raises an error' do
          expect { subject.run }.to raise_error(Berkshelf::ChefConnectionError, message)
        end
      end

      context 'when there is no value for :client_name' do
        before { chef_config.stub(node_name: nil) }
        let(:message) { 'Missing required attribute in your Berkshelf configuration: chef.node_name' }

        it 'raises an error' do
          expect { subject.run }.to raise_error(Berkshelf::ChefConnectionError, message)
        end
      end

      context 'when there is no value for :client_key' do
        before { chef_config.stub(client_key: nil) }
        let(:message) { 'Missing required attribute in your Berkshelf configuration: chef.client_key' }

        it 'raises an error' do
          expect {
            subject.run
          }.to raise_error(Berkshelf::ChefConnectionError, message)
        end
      end

      context 'when no options are given' do
        let(:ridley_options) do
          { server_url: 'http://configured-chef-server/' }.merge(default_ridley_options)
        end

        it 'uses the Berkshelf::Config options' do
          expect(Ridley).to receive(:open).with(
            server_url:  chef_config.chef_server_url,
            client_name: chef_config.node_name,
            client_key:  chef_config.client_key,
            ssl: {
              verify: berkshelf_config.ssl.verify
            }
          )
          subject.run
        end
      end

      context 'when a Chef Server url is passed as an option' do
        subject { Uploader.new(berksfile, server_url: 'http://custom') }

        it 'uses the passed in :server_url' do
          expect(Ridley).to receive(:open)
            .with(include(server_url: 'http://custom'))
          subject.run
        end
      end

      context 'when a client name is passed as an option' do
        subject { Uploader.new(berksfile, client_name: 'custom') }

        it 'uses the passed in :client_name' do
          expect(Ridley).to receive(:open)
            .with(include(client_name: 'custom'))
          subject.run
        end
      end

      context 'when a client key is passed as an option' do
        subject { Uploader.new(berksfile, client_key: 'custom') }

        it 'uses the passed in :client_key' do
          expect(Ridley).to receive(:open)
            .with(include(client_key: 'custom'))
          subject.run
        end
      end
    end
  end
end
