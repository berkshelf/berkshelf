require 'spec_helper'

describe Berkshelf::Lockfile do
  let!(:content) { File.read(fixtures_path.join('lockfiles/default.lock')) }
  let(:berksfile) { Berkshelf::Berksfile.new('Berksfile') }

  before do
    File.stub(:read).and_return(content)
  end

  describe '::initialize' do
    it 'does not throw an exception' do
      expect {
        Berkshelf::Lockfile.from_berksfile(berksfile)
      }.to_not raise_error
    end

    it 'has the correct dependencies' do
      expect(subject).to have_dependency 'build-essential'
      expect(subject).to have_dependency 'chef-client'
    end
  end

  subject { Berkshelf::Lockfile.from_berksfile(berksfile) }

  describe "#apply" do
    let(:env_name)    { 'berkshelf-test' }
    let(:server_url)  { Berkshelf::RSpec::ChefServer.server_url }
    let(:client_name) { 'berkshelf' }
    let(:client_key)  {
      "-----BEGIN RSA PRIVATE KEY-----
MIIEpQIBAAKCAQEAs3u5qfmdEWtzYHvXpbQRyefhUjeTG7nwhn/LaYY6ou19xxW0
I5MKSBqCxUCHqODRc7ox8zSF37x3jMBHbSczOcfbWsSe/qGnmvZZQhHmXCje2zkW
ByaRHmmatzkz1aAqAmZm/wdSuVLXytsbrPXuaj/MiHa6QH3e/ZFaYME7rMkouqfC
pUlSa2tZ9Ko1ZCCwjkiifuP4yQFsS6/G6b8c7F8wdq4byfJ9o6FN34lJHrzfG0ZV
hwS47Bdn6FDBQ6PVxrBsvQNE2n7QlNLfXWi4Tb8OpmQif01FjxleAr5kamx3GD+s
jC7fKHE9bZ0apZ1MVmkz9PhFmOigV5jl9Att+QIDAQABAoIBAQCCG6qXgQ9PVWkq
BBxrToGmr6UzCH5nlv65QWKfeGKBQU/wRdd0Al9trWomu4Sb831iOxOCjgyOB/1R
1wDwK36C4FIvFmF7jIwHVZWWw4sOO8JxgIxrWpXQShWRxLHCpnxNiRYYwaJCHb+4
meUSGKVf+Ce4tPiHT7eacQfnI6yyr1hWusKu0I8w7NsfeNc+/Rpne6mifLfaB/9u
b9kgfD15HGEsuUaMLZ/y1HFWvw2G2Og1cDrIpBIVtUAhA+DnjjLe/YoETeSmQAxH
ioQpJJ/gSqtTczIoyPXXiwaF5wUTQrsn5zZhTs9mAQy7hcSR92IH2xBSmK3+wlz0
vHZIq9rRAoGBAOeRUTRDgj+f+BlH1qFqf4EfkBN5quVM2808LYBGZWfA5/6o9jSN
AM84VXq3S8Wy5V6UMcSv4mOqEr3tEUYE8or9r/RxzpGahSdi8Ttju9vvpJH5I3xr
xx2ZK/vlrAfr6JHlE4bqqc5unCslUt2/liCWpERQ3cFcPydQb7Imrm+DAoGBAMZr
mcxBeMyQHG6Kcpc7EQXZ5i7a8T6ksPu7FbAZ70Meb9UMtVIYpVBalutCXKhl7D4K
qrCmV2gQryBz+S7AecFZSKvXdb7ueYzf8EcI/v+loNu9v9/4m4YV3bPBkMhW5kcK
xFnVIsYqUlR+dsS8JfjSCpk4lePVSSt7B26eIFfTAoGBAJHPDKSuBWtunNe+RkUp
O9PgPeYlbBgqBxT52WS17tAfxXSyiySXzHSuchRtKgb4GDkvcw73+MLsqhRxG7lN
EDO4fXyb1IgWFdWxFVhh+j4IbUWE7HVBoAThF7Lq8SGjx7Nl3J/NTtKvDyKTw9Pg
+PTYJeLmUFuabCGjIlG4zYllAoGBAIwe5oB4597GEl35xUyI+M+B/myuTtknIpjS
mFFBL1bdwqnYjJ+KKgwhvRwsRBTjzT5O+BVBks45ogKwA5OBdzoUXB6GTG9mJ05V
wm/XqYRNqdgkGsEG5oV9IZBUrHLd80bOErVBr4nzzyo+GI98MvCRG8zySd+X+lEL
U8dJQZvjAoGAWorll+fomfie6t5XbkpwMo8rn60yFUiRE7HWxA2qDj3IpoE6SfNE
eOpsf1Zzx30r8answ9lPnd753ACdgNzE66ScWD+cQeB6OlMZMaW5tVSjddZ7854L
00znt8b1OLkVY33xfsa89wKH343304BhVHABPMxm5Leua/H21/BqSK0=
-----END RSA PRIVATE KEY-----
"
    }
    let(:ridley) { Ridley.new(server_url: server_url, client_name: client_name, client_key: client_key) }

    before do
      Berkshelf.stub(:ridley_connection).and_yield(ridley)
      berksfile.add_dependency('nginx', '>= 0.1.2')
    end

    context "when the chef environment exists" do
      let(:dependencies) do
        [
          double(name: 'nginx', locked_version: '1.2.3'),
          double(name: 'artifact', locked_version: '1.4.0')
        ]
      end

      before do
        chef_environment(env_name)
        subject.stub(:dependencies).and_return(dependencies)
      end

      # it "test", focus: true do
      #   p client_key
      #   p File.read(client_key)
      #   # p ridley.environment.find(env_name)
      # end

      it "applys the locked_versions of the Lockfile dependencies to the given Chef environment" do
        subject.apply(env_name)

        environment = ::JSON.parse(chef_server.data_store.get(['environments', env_name]))
        expect(environment['cookbook_versions']).to have(2).items
        expect(environment['cookbook_versions']['nginx']).to eq('= 1.2.3')
        expect(environment['cookbook_versions']['artifact']).to eq('= 1.4.0')
      end
    end

    context "when the environment does not exist" do
      it "raises an EnvironmentNotFound error" do
        expect {
          subject.apply("not-there")
        }.to raise_error(Berkshelf::EnvironmentNotFound)
      end
    end
  end

  describe '#dependencies' do
    it 'returns an array' do
      expect(subject.dependencies).to be_a(Array)
    end
  end

  describe '#find' do
    it 'returns a matching cookbook' do
      expect(subject.find('build-essential').name).to eq 'build-essential'
    end

    it 'returns nil for a missing cookbook' do
      expect(subject.find('foo')).to be_nil
    end
  end

  describe '#has_dependency?' do
    it 'returns true if a matching cookbook is found' do
      expect(subject.has_dependency?('build-essential')).to be_true
    end

    it 'returns false if no matching cookbook is found' do
      expect(subject.has_dependency?('foo')).to be_false
    end
  end

  describe '#update' do
    it 'resets the dependencies' do
      subject.should_receive(:reset_dependencies!).once
      subject.update([])
    end

    it 'appends each of the dependencies' do
      dependency = double('dependency')
      subject.should_receive(:append).with(dependency).once
      subject.update([dependency])
    end

    it 'saves the file' do
      subject.should_receive(:save).once
      subject.update([])
    end
  end

  describe '#add' do
    let(:dependency) { double('dependency', name: 'build-essential') }

    it 'adds the new dependency to the @dependencies instance variable' do
      subject.add(dependency)
      expect(subject).to have_dependency(dependency)
    end

    it 'does not add duplicate dependencies' do
      5.times { subject.add(dependency) }
      expect(subject).to have_dependency(dependency)
    end
  end

  describe '#remove' do
    let(:dependency) { double('dependency', name: 'build-essential') }

    before do
      subject.add(dependency)
    end

    it 'removes the dependency' do
      subject.remove(dependency)
      expect(subject).to_not have_dependency(dependency)
    end

    it 'raises an except if the dependency does not exist' do
      expect {
        subject.remove(nil)
      }.to raise_error Berkshelf::CookbookNotFound
    end
  end

  describe '#to_hash' do
    let(:hash) { subject.to_hash }

    it 'has the `:dependencies` key' do
      expect(hash).to have_key(:dependencies)
    end
  end

  describe '#to_json' do
    it 'dumps the #to_hash to JSON' do
      JSON.should_receive(:pretty_generate).with(subject.to_hash, {})
      subject.to_json
    end
  end

  describe '#save' do
    before { Berkshelf::Lockfile.send(:public, :save) }
    let(:file) { double('file') }

    before(:each) do
      File.stub(:open).with('Berksfile.lock', 'w')
    end

    it 'saves itself to a file on disk' do
      File.should_receive(:open).with(/(.+)\/Berksfile\.lock/, 'w').and_yield(file)
      file.should_receive(:write).once
      subject.save
    end
  end

  describe '#reset_dependencies!' do
    before { Berkshelf::Lockfile.send(:public, :reset_dependencies!) }

    it 'sets the dependencies to an empty hash' do
      expect {
        subject.reset_dependencies!
      }.to change { subject.dependencies }.to([])
    end
  end

  describe '#cookbook_name' do
    before { Berkshelf::Lockfile.send(:public, :cookbook_name) }

    it 'accepts a cookbook dependency' do
      dependency = double('dependency', name: 'build-essential', is_a?: true)
      expect(subject.cookbook_name(dependency)).to eq 'build-essential'
    end

    it 'accepts a string' do
      expect(subject.cookbook_name('build-essential')).to eq 'build-essential'
    end
  end
end
