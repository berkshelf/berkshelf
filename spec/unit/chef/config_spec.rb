require 'spec_helper'

describe Berkshelf::Chef::Config do
  describe '.path' do
    let(:path) { '/fake/path/for/.chef' }
    let(:config) { File.join(path, 'knife.rb') }

    before do
      ENV.stub(:[]).and_return(nil)

      File.stub(:exists?).with(any_args()).and_return(false)
      File.stub(:exists?).with(config).and_return(true)

      Berkshelf::Chef::Config.instance_variable_set(:@path, nil)
    end

    it 'uses $BERKSHELF_CHEF_CONFIG' do
      ENV.stub(:[]).with('BERKSHELF_CHEF_CONFIG').and_return(config)
      expect(Berkshelf::Chef::Config.path).to eq(config)
    end

    it 'uses $KNIFE_HOME' do
      ENV.stub(:[]).with('KNIFE_HOME').and_return(path)
      expect(Berkshelf::Chef::Config.path).to eq(config)
    end

    it 'uses ::working_dir' do
      Berkshelf::Chef::Config.stub(:working_dir).and_return(path)
      expect(Berkshelf::Chef::Config.path).to eq(config)
    end

    context 'an ascending search' do
      context 'with multiple .chef directories' do
        let(:path) { '/fake/.chef/path/with/multiple/.chef/directories' }

        before do
          Berkshelf::Chef::Config.stub(:working_dir).and_return(path)
          File.stub(:exists?).and_return(false)
          File.stub(:exists?).with('/fake/.chef/knife.rb').and_return(true)
          File.stub(:exists?).with('/fake/.chef/path/with/multiple/.chef/knife.rb').and_return(true)
        end

        it 'chooses the closest path' do
          expect(Berkshelf::Chef::Config.path).to eq('/fake/.chef/path/with/multiple/.chef/knife.rb')
        end
      end

      context 'with the current directory as .chef' do
        let(:path) { '/fake/.chef' }

        before do
          Berkshelf::Chef::Config.stub(:working_dir).and_return(path)
          File.stub(:exists?).and_return(false)
          File.stub(:exists?).with('/fake/.chef/knife.rb').and_return(true)
        end

        it 'uses the current directory' do
          expect(Berkshelf::Chef::Config.path).to eq('/fake/.chef/knife.rb')
        end
      end

      context 'with .chef at the top-level' do
        let(:path) { '/.chef/some/random/sub/directories' }

        before do
          Berkshelf::Chef::Config.stub(:working_dir).and_return(path)
          File.stub(:exists?).and_return(false)
          File.stub(:exists?).with('/.chef/knife.rb').and_return(true)
        end

        it 'uses the top-level directory' do
          expect(Berkshelf::Chef::Config.path).to eq('/.chef/knife.rb')
        end
      end
    end

    it 'uses $HOME' do
      ENV.stub(:[]).with('HOME').and_return(File.join(path, '..'))
      expect(Berkshelf::Chef::Config.path).to eq(config)
    end
  end
end
