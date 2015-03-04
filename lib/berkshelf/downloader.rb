require 'net/http'
require 'zlib'
require 'archive/tar/minitar'

module Berkshelf
  class Downloader
    extend Forwardable

    attr_reader :berksfile

    def_delegators :berksfile, :sources

    # @param [Berkshelf::Berksfile] berksfile
    def initialize(berksfile)
      @berksfile = berksfile
    end

    # Download the given Berkshelf::Dependency. If the optional block is given,
    # the temporary path to the cookbook is yielded and automatically deleted
    # when the block returns. If no block is given, it is the responsibility of
    # the caller to remove the tmpdir.
    #
    # @param [String] name
    # @param [String] version
    #
    # @option options [String] :path
    #
    # @raise [CookbookNotFound]
    #
    # @return [String]
    def download(*args, &block)
      options = args.last.is_a?(Hash) ? args.pop : Hash.new
      dependency, version = args

      sources.each do |source|
        if result = try_download(source, dependency, version)
          if block_given?
            value = yield result
            FileUtils.rm_rf(result)
            return value
          end

          return result
        end
      end

      raise CookbookNotFound.new(dependency, version, 'in any of the sources')
    end

    # @param [Berkshelf::Source] source
    # @param [String] name
    # @param [String] version
    #
    # @return [String]
    def try_download(source, name, version)
      unless remote_cookbook = source.cookbook(name, version)
        return nil
      end

      case remote_cookbook.location_type
      when :opscode, :supermarket
        CommunityREST.new(remote_cookbook.location_path).download(name, version)
      when :chef_server
        # @todo Dynamically get credentials for remote_cookbook.location_path
        credentials = {
          server_url: remote_cookbook.location_path,
          client_name: Berkshelf::Config.instance.chef.node_name,
          client_key: Berkshelf::Config.instance.chef.client_key,
          ssl: {
            verify: Berkshelf::Config.instance.ssl.verify
          }
        }
        # @todo  Something scary going on here - getting an instance of Kitchen::Logger from test-kitchen
        # https://github.com/opscode/test-kitchen/blob/master/lib/kitchen.rb#L99
        Celluloid.logger = nil unless ENV["DEBUG_CELLULOID"]
        Ridley.open(credentials) { |r| r.cookbook.download(name, version) }
      when :github
        Thread.exclusive { require 'octokit' unless defined?(Octokit) }

        tmp_dir      = Dir.mktmpdir
        archive_path = File.join(tmp_dir, "#{name}-#{version}.tar.gz")
        unpack_dir   = File.join(tmp_dir, "#{name}-#{version}")

        # Find the correct github connection options for this specific cookbook.
        cookbook_uri = URI.parse(remote_cookbook.location_path)
        if cookbook_uri.host == "github.com"
          options = Berkshelf::Config.instance.github.detect { |opts| opts["web_endpoint"] == nil }
          options = {} if options == nil
        else
          options = Berkshelf::Config.instance.github.detect { |opts| opts["web_endpoint"] == "#{cookbook_uri.scheme}://#{cookbook_uri.host}" }
          raise ConfigurationError.new "Missing github endpoint configuration for #{cookbook_uri.scheme}://#{cookbook_uri.host}" if options == nil
        end

        github_client = Octokit::Client.new(access_token: options[:access_token],
          api_endpoint: options[:api_endpoint], web_endpoint: options[:web_endpoint],
          connection_options: {ssl: {verify: options[:ssl_verify].nil? ? true : options[:ssl_verify]}})

        begin
          url = URI(github_client.archive_link(cookbook_uri.path.gsub(/^\//, ""), ref: "v#{version}"))
        rescue Octokit::Unauthorized
          return nil
        end

        Net::HTTP.start(url.host, use_ssl: url.scheme == "https",
          verify_mode: (options[:ssl_verify].nil? || options[:ssl_verify]) ? OpenSSL::SSL::VERIFY_PEER : OpenSSL::SSL::VERIFY_NONE) do |http|
          resp = http.get(url.request_uri)
          return nil unless resp.is_a?(Net::HTTPSuccess)
          open(archive_path, "wb") { |file| file.write(resp.body) }
        end

        tgz = Zlib::GzipReader.new(File.open(archive_path, "rb"))
        Archive::Tar::Minitar.unpack(tgz, unpack_dir)

        # we need to figure out where the cookbook is located in the archive. This is because the directory name
        # pattern is not cosistant between private and public github repositories
        cookbook_directory = Dir.entries(unpack_dir).select do |f|
          (! f.start_with?('.')) && (Pathname.new(File.join(unpack_dir, f)).cookbook?)
        end[0]

        File.join(unpack_dir, cookbook_directory)
      when :uri
        Thread.exclusive { require 'open-uri' unless defined?(OpenURI) }

        tmp_dir      = Dir.mktmpdir
        archive_path = Pathname.new(tmp_dir) + "#{name}-#{version}.tar.gz"
        unpack_dir   = Pathname.new(tmp_dir) + "#{name}-#{version}"

        url = remote_cookbook.location_path
        open(url, 'rb') do |remote_file|
          archive_path.open('wb') { |local_file| local_file.write remote_file.read }
        end

        archive_path.open('rb') do |file|
          tgz = Zlib::GzipReader.new(file)
          Archive::Tar::Minitar.unpack(tgz, unpack_dir.to_s)
        end

        # The top level directory is inconsistant. So we unpack it and
        # use the only directory created in the unpack_dir.
        cookbook_directory = unpack_dir.entries.select do |filename|
          (! filename.to_s.start_with?('.')) && (unpack_dir + filename).cookbook?
        end.first

        (unpack_dir + cookbook_directory).to_s
      when :file_store
        tmp_dir = Dir.mktmpdir
        FileUtils.cp_r(remote_cookbook.location_path, tmp_dir)
        File.join(tmp_dir, name)
      else
        raise RuntimeError, "unknown location type #{remote_cookbook.location_type}"
      end
    rescue CookbookNotFound
      nil
    end
  end
end
