require 'rubygems'
require 'bundler'
require 'spork'
require 'webmock/rspec'

Spork.prefork do
  require 'rspec'
  require 'simplecov'
  require 'pp'
  
  APP_ROOT = File.expand_path('../../', __FILE__)
  
  Dir[File.join(APP_ROOT, "spec/support/**/*.rb")].each {|f| require f}

  RSpec.configure do |config|    
    config.mock_with :rspec
    config.treat_symbols_as_metadata_keys_with_true_values = true
    config.filter_run :focus => true
    config.run_all_when_everything_filtered = true

    config.before do
      stub_request(:get, "http://cookbooks.opscode.com/api/v1/cookbooks/mysql").
        with(:headers => {'Accept'=>'application/json', 'User-Agent'=>'Chef Knife/0.10.8 (ruby-1.9.3-p125; ohai-0.6.12; x86_64-darwin11.3.0; +http://opscode.com)', 'X-Chef-Version'=>'0.10.8'}).
        to_return(:status => 200, :body => <<RESPONSE, :headers => {'Content-Type' => "application/json"})
{"updated_at":"2012-03-20T03:32:50Z","category":"Databases","maintainer":"opscode","latest_version":"http://cookbooks.opscode.com/api/v1/cookbooks/mysql/versions/1_2_4","external_url":"github.com/opscode-cookbooks/mysql","name":"mysql","versions":["http://cookbooks.opscode.com/api/v1/cookbooks/mysql/versions/1_2_4","http://cookbooks.opscode.com/api/v1/cookbooks/mysql/versions/1_2_2","http://cookbooks.opscode.com/api/v1/cookbooks/mysql/versions/1_2_1","http://cookbooks.opscode.com/api/v1/cookbooks/mysql/versions/1_0_8","http://cookbooks.opscode.com/api/v1/cookbooks/mysql/versions/1_0_7","http://cookbooks.opscode.com/api/v1/cookbooks/mysql/versions/1_0_6","http://cookbooks.opscode.com/api/v1/cookbooks/mysql/versions/1_0_5","http://cookbooks.opscode.com/api/v1/cookbooks/mysql/versions/1_0_4","http://cookbooks.opscode.com/api/v1/cookbooks/mysql/versions/1_0_3","http://cookbooks.opscode.com/api/v1/cookbooks/mysql/versions/1_0_2","http://cookbooks.opscode.com/api/v1/cookbooks/mysql/versions/1_0_1","http://cookbooks.opscode.com/api/v1/cookbooks/mysql/versions/1_0_0","http://cookbooks.opscode.com/api/v1/cookbooks/mysql/versions/0_24_4","http://cookbooks.opscode.com/api/v1/cookbooks/mysql/versions/0_24_3","http://cookbooks.opscode.com/api/v1/cookbooks/mysql/versions/0_24_2","http://cookbooks.opscode.com/api/v1/cookbooks/mysql/versions/0_24_1","http://cookbooks.opscode.com/api/v1/cookbooks/mysql/versions/0_24_0","http://cookbooks.opscode.com/api/v1/cookbooks/mysql/versions/0_23_1","http://cookbooks.opscode.com/api/v1/cookbooks/mysql/versions/0_23_0","http://cookbooks.opscode.com/api/v1/cookbooks/mysql/versions/0_22_0","http://cookbooks.opscode.com/api/v1/cookbooks/mysql/versions/0_21_5","http://cookbooks.opscode.com/api/v1/cookbooks/mysql/versions/0_21_3","http://cookbooks.opscode.com/api/v1/cookbooks/mysql/versions/0_21_2","http://cookbooks.opscode.com/api/v1/cookbooks/mysql/versions/0_21_1","http://cookbooks.opscode.com/api/v1/cookbooks/mysql/versions/0_21_0","http://cookbooks.opscode.com/api/v1/cookbooks/mysql/versions/0_20_0","http://cookbooks.opscode.com/api/v1/cookbooks/mysql/versions/0_15_0","http://cookbooks.opscode.com/api/v1/cookbooks/mysql/versions/0_10_0"],"description":"Installs and configures mysql for client or server","created_at":"2009-10-28T19:16:54Z","average_rating":4.76923}
RESPONSE
      stub_request(:get, "http://cookbooks.opscode.com/api/v1/cookbooks/mysql/versions/1_2_4").
        with(:headers => {'Accept'=>'application/json', 'User-Agent'=>'Chef Knife/0.10.8 (ruby-1.9.3-p125; ohai-0.6.12; x86_64-darwin11.3.0; +http://opscode.com)', 'X-Chef-Version'=>'0.10.8'}).
        to_return(:status => 200, :body => <<RESPONSE, :headers => {'Content-Type' => 'application/json'})
{"updated_at":"2012-02-16T23:23:23Z","file":"http://s3.amazonaws.com/community-files.opscode.com/cookbook_versions/tarballs/1349/original/mysql.tgz","cookbook":"http://cookbooks.opscode.com/api/v1/cookbooks/mysql","tarball_file_size":10008,"license":"Apache 2.0","average_rating":null,"created_at":"2012-02-16T23:23:23Z","version":"1.2.4"}
RESPONSE
      stub_request(:get, "http://s3.amazonaws.com/community-files.opscode.com/cookbook_versions/tarballs/1349/original/mysql.tgz").
        with(:headers => {'Accept'=>'*/*', 'User-Agent'=>'Chef Knife/0.10.8 (ruby-1.9.3-p125; ohai-0.6.12; x86_64-darwin11.3.0; +http://opscode.com)', 'X-Chef-Version'=>'0.10.8'}).
        to_return(:status => 200, :body => file_fixture('mysql.tgz'), :headers => {})

      stub_request(:get, "http://cookbooks.opscode.com/api/v1/cookbooks/openssl").
        with(:headers => {'Accept'=>'application/json', 'User-Agent'=>'Chef Knife/0.10.8 (ruby-1.9.3-p125; ohai-0.6.12; x86_64-darwin11.3.0; +http://opscode.com)', 'X-Chef-Version'=>'0.10.8'}).
        to_return(:status => 200, :body => <<RESPONSE, :headers => {'Content-Type' => 'application/json'})
{"average_rating":5.0,"name":"openssl","created_at":"2010-02-26T22:37:56Z","category":"Utilities","updated_at":"2012-03-20T03:31:42Z","latest_version":"http://cookbooks.opscode.com/api/v1/cookbooks/openssl/versions/1_0_0","maintainer":"opscode","external_url":"github.com/opscode-cookbooks/openssl","versions":["http://cookbooks.opscode.com/api/v1/cookbooks/openssl/versions/1_0_0","http://cookbooks.opscode.com/api/v1/cookbooks/openssl/versions/0_1_0"],"description":"Provides a library with a method for generating secure random passwords."}
RESPONSE
      stub_request(:get, "http://cookbooks.opscode.com/api/v1/cookbooks/openssl/versions/1_0_0").
        with(:headers => {'Accept'=>'application/json', 'User-Agent'=>'Chef Knife/0.10.8 (ruby-1.9.3-p125; ohai-0.6.12; x86_64-darwin11.3.0; +http://opscode.com)', 'X-Chef-Version'=>'0.10.8'}).
        to_return(:status => 200, :body => <<RESPONSE, :headers => {'Content-Type' => 'application/json'})
{"average_rating":null,"created_at":"2011-06-04T02:50:06Z","tarball_file_size":1604,"updated_at":"2011-06-04T02:50:06Z","license":"Apache 2.0","version":"1.0.0","file":"http://s3.amazonaws.com/community-files.opscode.com/cookbook_versions/tarballs/765/original/openssl.tgz","cookbook":"http://cookbooks.opscode.com/api/v1/cookbooks/openssl"}
RESPONSE

      stub_request(:get, "http://s3.amazonaws.com/community-files.opscode.com/cookbook_versions/tarballs/765/original/openssl.tgz").
        with(:headers => {'Accept'=>'*/*', 'User-Agent'=>'Chef Knife/0.10.8 (ruby-1.9.3-p125; ohai-0.6.12; x86_64-darwin11.3.0; +http://opscode.com)', 'X-Chef-Version'=>'0.10.8'}).
        to_return(:status => 200, :body => file_fixture('openssl.tgz'), :headers => {})
    end



    config.after do
      KnifeCookbookDependencies.clean
    end
  end

  SimpleCov.start do
    add_filter 'spec/'
  end

  def file_fixture(filename)
    File.new(File.join(File.dirname(__FILE__), 'fixtures', 'files', filename))
  end

  def capture(stream)
    begin
      stream = stream.to_s
      eval "$#{stream} = StringIO.new"
      yield
      result = eval("$#{stream}").string
    ensure
      eval("$#{stream} = #{stream.upcase}")
    end

    result
  end

  def example_cookbook_from_path
    @example_cookbook_from_path ||= KCD::Cookbook.new('example_cookbook', path: File.join(File.dirname(__FILE__), 'fixtures', 'cookbooks'))
  end

  def with_cookbookfile content
    Dir.chdir(ENV['TMPDIR']) do
      File.open('Cookbookfile', 'w') do |f|
        f.write content
      end
      yield
    end
  end

end

Spork.each_run do
  require 'kcd'
end
