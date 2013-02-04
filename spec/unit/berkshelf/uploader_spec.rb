require 'spec_helper'

describe Berkshelf::Uploader, :chef_server do
  subject do
    Berkshelf::Uploader.new(
      server_url: Chef::Config[:chef_server_url],
      client_key: Chef::Config[:client_key],
      client_name: Chef::Config[:node_name]
    )
  end

  describe '#upload' do
    let(:cookbook) { double('nginx', name: 'nginx-0.101.2', cookbook_name: 'nginx', version: '0.101.2', to_json: nil) }
    let(:checksums) { { 'nginx' => 'dsjkl224rjlkadu08fda' } }
    let(:conn) { double('conn') }
    let(:sandbox) { double('sandbox') }

    context 'when cookbook is invalid' do
      before do
        cookbook.stub(:validate!).and_raise(::Berkshelf::CookbookSyntaxError)
      end

      it 'raises a CookbookSyntaxError error' do
        expect {
          subject.upload(cookbook)
        }.to raise_error(::Berkshelf::CookbookSyntaxError)
      end
    end
  end
end
