require 'spec_helper'

describe Berkshelf::ChefAPILocation, :chef_server do
  let(:test_chef_api) { 'https://chefserver:8081' }
  let(:node_name) { 'reset' }
  let(:client_key) { fixtures_path.join('reset.pem').to_s }

  let(:valid_uri) { test_chef_api }
  let(:invalid_uri) { 'notauri' }
  let(:constraint) { double('constraint') }

  describe '.initialize' do
    subject do
      Berkshelf::ChefAPILocation.new('nginx',
        constraint,
        chef_api: test_chef_api,
        node_name: node_name,
        client_key: client_key
      )
    end

    it 'sets the uri attribute to the value of the chef_api option' do
      expect(subject.uri).to eq(test_chef_api)
    end

    it 'sets the node_name attribute to the value of the node_name option' do
      expect(subject.node_name).to eq(node_name)
    end

    it 'sets the client_key attribute to the value of the client_key option' do
      expect(subject.client_key).to eq(client_key)
    end

    context 'when an invalid Chef API URI is given' do
      it 'raises Berkshelf::InvalidChefAPILocation' do
        expect {
          Berkshelf::ChefAPILocation.new("nginx", constraint, chef_api: invalid_uri, node_name: node_name, client_key: client_key)
        }.to raise_error(Berkshelf::InvalidChefAPILocation, "'notauri' is not a valid Chef API URI.")
      end
    end

    context 'when no option for node_name is supplied' do
      it 'raises Berkshelf::InvalidChefAPILocation' do
        expect {
          Berkshelf::ChefAPILocation.new('nginx', constraint, chef_api: invalid_uri, client_key: client_key)
        }.to raise_error(Berkshelf::InvalidChefAPILocation)
      end
    end

    context 'when no option for client_key is supplied' do
      it 'raises Berkshelf::InvalidChefAPILocation' do
        expect {
          Berkshelf::ChefAPILocation.new('nginx', constraint, chef_api: invalid_uri, node_name: node_name)
        }.to raise_error(Berkshelf::InvalidChefAPILocation)
      end
    end

    context 'given the symbol :config for the value of chef_api:' do
      subject do
        Berkshelf::ChefAPILocation.new('nginx', constraint, chef_api: :config)
      end

      it 'uses the value of Berkshelf::Chef.instance.chef.chef_server_url for the uri attribute' do
        expect(subject.uri).to eq(Berkshelf::Config.instance.chef.chef_server_url)
      end

      it 'uses the value of Berkshelf::Chef.instance.chef.node_name for the node_name attribute' do
        expect(subject.node_name).to eq(Berkshelf::Config.instance.chef.node_name)
      end

      it 'uses the value of Berkshelf::Chef.instance.chef.client_key for the client_key attribute' do
        expect(subject.client_key).to eq(Berkshelf::Config.instance.chef.client_key)
      end
    end
  end

  describe '.validate_uri' do
    it 'returns false if the given URI is invalid' do
      expect(Berkshelf::ChefAPILocation.validate_uri(invalid_uri)).to be_false
    end

    it 'returns true if the given URI is valid' do
      expect(Berkshelf::ChefAPILocation.validate_uri(valid_uri)).to be_true
    end
  end

  describe '.validate_uri!' do
    it 'raises Berkshelf::InvalidChefAPILocation if the given URI is invalid' do
      expect {
        Berkshelf::ChefAPILocation.validate_uri!(invalid_uri)
      }.to raise_error(Berkshelf::InvalidChefAPILocation, "'notauri' is not a valid Chef API URI.")
    end

    it 'returns true if the given URI is valid' do
      expect(Berkshelf::ChefAPILocation.validate_uri!(valid_uri)).to be_true
    end
  end



  subject do
    Berkshelf::ChefAPILocation.new('nginx',
      nil,
      chef_api: test_chef_api,
      node_name: node_name,
      client_key: client_key
    )
  end

  describe '#target_cookbook' do
    let(:cookbook_version) { double('cookbook_version') }

    context 'when a version constraint is present' do
      let(:constraint) { double('constraint') }

      it 'returns the best solution for the constraint' do
        subject.stub(:version_constraint).and_return(constraint)
        subject.stub_chain(:conn, :cookbook, :satisfy).with(subject.name, constraint).and_return(cookbook_version)

        expect(subject.target_cookbook).to eq(cookbook_version)
      end
    end

    context 'when a version constraint is not present' do
      it 'returns the latest version of the cookbook' do
        subject.stub(:version_constraint).and_return(nil)
        subject.stub_chain(:conn, :cookbook, :latest_version).with(subject.name).and_return(cookbook_version)

        expect(subject.target_cookbook).to eq(cookbook_version)
      end
    end
  end

  describe '#to_s' do
    it 'returns a string containing the location key and the Chef API URI' do
      expect(subject.to_s).to eq("chef_api: '#{test_chef_api}'")
    end
  end
end
