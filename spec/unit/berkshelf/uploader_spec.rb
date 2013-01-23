require 'spec_helper'

module Berkshelf
  describe Uploader, :chef_server do
    subject { Uploader.new(server_url: Chef::Config[:chef_server_url], client_key: Chef::Config[:client_key], client_name: Chef::Config[:node_name]) }

    describe '#upload' do
      let(:cookbook) { double('nginx', name: 'nginx-0.101.2', cookbook_name: 'nginx', version: '0.101.2', to_json: nil) }
      let(:checksums) { { 'nginx' => 'dsjkl224rjlkadu08fda' } }
      let(:conn) { double('conn') }
      let(:sandbox) { double('sandbox') }

      before do
        ::Ridley.stub(:connection).and_return(conn)
        cookbook.stub(:validate!).and_return(true)
        cookbook.stub(:checksums).and_return(checksums)
        checksums.stub(:dup).and_return(checksums)
        conn.stub(:sandbox).and_return(sandbox)
        conn.stub(:cookbook).and_return(cookbook)
        sandbox.stub(:create).and_return(sandbox)
      end

      it 'uploads the sandbox' do
        ::Mutex.should_receive(:new).with(no_args())
        cookbook.should_receive(:checksums).once.and_return(checksums)
        checksums.should_receive(:dup).once
        conn.should_receive(:sandbox).once
        sandbox.should_receive(:create).once.with(['nginx'])
        sandbox.should_receive(:multi_upload).once.with(checksums)
        sandbox.should_receive(:commit).once
        sandbox.should_receive(:terminate).once
        conn.should_receive(:cookbook).once
        cookbook.should_receive(:save).once.with('nginx', '0.101.2', nil, {})

        subject.upload(cookbook)
      end

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
end
