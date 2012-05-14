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

      stub_request(:get, "http://cookbooks.opscode.com/api/v1/cookbooks/nginx").
        with(:headers => {'Accept'=>'application/json', 'User-Agent'=>'Chef Knife/0.10.8 (ruby-1.9.3-p125; ohai-0.6.12; x86_64-darwin11.3.0; +http://opscode.com)', 'X-Chef-Version'=>'0.10.8'}).
        to_return(:status => 200, :body => <<RESPONSE, :headers => {'Content-Type' => 'application/json'})
{"average_rating":4.0,"name":"nginx","created_at":"2009-10-25T23:52:41Z","category":"Web Servers","updated_at":"2012-04-19T21:40:04Z","latest_version":"http://cookbooks.opscode.com/api/v1/cookbooks/nginx/versions/0_101_2","maintainer":"opscode","external_url":"github.com/opscode-cookbooks/nginx","versions":["http://cookbooks.opscode.com/api/v1/cookbooks/nginx/versions/0_101_2","http://cookbooks.opscode.com/api/v1/cookbooks/nginx/versions/0_101_0","http://cookbooks.opscode.com/api/v1/cookbooks/nginx/versions/0_100_2","http://cookbooks.opscode.com/api/v1/cookbooks/nginx/versions/0_100_0","http://cookbooks.opscode.com/api/v1/cookbooks/nginx/versions/0_99_2","http://cookbooks.opscode.com/api/v1/cookbooks/nginx/versions/0_99_0","http://cookbooks.opscode.com/api/v1/cookbooks/nginx/versions/0_14_4","http://cookbooks.opscode.com/api/v1/cookbooks/nginx/versions/0_14_3","http://cookbooks.opscode.com/api/v1/cookbooks/nginx/versions/0_14_2","http://cookbooks.opscode.com/api/v1/cookbooks/nginx/versions/0_14_1","http://cookbooks.opscode.com/api/v1/cookbooks/nginx/versions/0_14_0","http://cookbooks.opscode.com/api/v1/cookbooks/nginx/versions/0_12_1","http://cookbooks.opscode.com/api/v1/cookbooks/nginx/versions/0_10_0","http://cookbooks.opscode.com/api/v1/cookbooks/nginx/versions/0_8_0"],"description":"Installs and configures nginx"}
RESPONSE
      stub_request(:get, "http://cookbooks.opscode.com/api/v1/cookbooks/nginx/versions/0_101_2").
        with(:headers => {'Accept'=>'application/json', 'User-Agent'=>'Chef Knife/0.10.8 (ruby-1.9.3-p125; ohai-0.6.12; x86_64-darwin11.3.0; +http://opscode.com)', 'X-Chef-Version'=>'0.10.8'}).
        to_return(:status => 200, :body => <<RESPONSE, :headers => {'Content-Type' => 'application/json'})
{"average_rating":null,"created_at":"2012-04-19T21:39:47Z","tarball_file_size":17024,"updated_at":"2012-04-19T21:39:47Z","license":"Apache 2.0","version":"0.101.2","file":"http://s3.amazonaws.com/community-files.opscode.com/cookbook_versions/tarballs/1530/original/nginx.tgz","cookbook":"http://cookbooks.opscode.com/api/v1/cookbooks/nginx"}
RESPONSE
      stub_request(:get, "http://cookbooks.opscode.com/api/v1/cookbooks/nginx/versions/0_101_0").
        with(:headers => {'Accept'=>'application/json', 'User-Agent'=>'Chef Knife/0.10.8 (ruby-1.9.3-p125; ohai-0.6.12; x86_64-darwin11.3.0; +http://opscode.com)', 'X-Chef-Version'=>'0.10.8'}).
        to_return(:status => 200, :body => <<RESPONSE, :headers => {'Content-Type' => 'application/json'})
{"updated_at":"2012-04-06T19:15:15Z","file":"http://s3.amazonaws.com/community-files.opscode.com/cookbook_versions/tarballs/1487/original/nginx.tgz","cookbook":"http://cookbooks.opscode.com/api/v1/cookbooks/nginx","tarball_file_size":16996,"license":"Apache 2.0","average_rating":null,"created_at":"2012-04-06T19:15:15Z","version":"0.101.0"}
RESPONSE
      stub_request(:get, "http://s3.amazonaws.com/community-files.opscode.com/cookbook_versions/tarballs/1530/original/nginx.tgz"). # nginx 0.101.2
        with(:headers => {'Accept'=>'*/*', 'User-Agent'=>'Chef Knife/0.10.8 (ruby-1.9.3-p125; ohai-0.6.12; x86_64-darwin11.3.0; +http://opscode.com)', 'X-Chef-Version'=>'0.10.8'}).
        to_return(:status => 200, :body => file_fixture('nginx.tgz'), :headers => {})
      stub_request(:get, "http://s3.amazonaws.com/community-files.opscode.com/cookbook_versions/tarballs/1487/original/nginx.tgz"). # nginx 0.101.0
        with(:headers => {'Accept'=>'*/*', 'User-Agent'=>'Chef Knife/0.10.8 (ruby-1.9.3-p125; ohai-0.6.12; x86_64-darwin11.3.0; +http://opscode.com)', 'X-Chef-Version'=>'0.10.8'}).
        to_return(:status => 200, :body => file_fixture('nginx101_0.tgz'), :headers => {})

      stub_request(:get, "http://cookbooks.opscode.com/api/v1/cookbooks/ntp").
        with(:headers => {'Accept'=>'application/json', 'User-Agent'=>'Chef Knife/0.10.8 (ruby-1.9.3-p125; ohai-0.6.12; x86_64-darwin11.3.0; +http://opscode.com)', 'X-Chef-Version'=>'0.10.8'}).
        to_return(:status => 200, :body => <<RESPONSE, :headers => {'Content-Type' => 'application/json'})
{"updated_at":"2012-04-19T21:56:25Z","category":"Networking","maintainer":"opscode","latest_version":"http://cookbooks.opscode.com/api/v1/cookbooks/ntp/versions/1_1_8","external_url":"github.com/opscode-cookbooks/ntp","name":"ntp","versions":["http://cookbooks.opscode.com/api/v1/cookbooks/ntp/versions/1_1_8","http://cookbooks.opscode.com/api/v1/cookbooks/ntp/versions/1_1_6","http://cookbooks.opscode.com/api/v1/cookbooks/ntp/versions/1_1_4","http://cookbooks.opscode.com/api/v1/cookbooks/ntp/versions/1_1_2","http://cookbooks.opscode.com/api/v1/cookbooks/ntp/versions/1_1_0","http://cookbooks.opscode.com/api/v1/cookbooks/ntp/versions/1_0_1","http://cookbooks.opscode.com/api/v1/cookbooks/ntp/versions/1_0_0","http://cookbooks.opscode.com/api/v1/cookbooks/ntp/versions/0_8_2","http://cookbooks.opscode.com/api/v1/cookbooks/ntp/versions/0_8_1","http://cookbooks.opscode.com/api/v1/cookbooks/ntp/versions/0_7_0"],"description":"Installs and configures ntp as a client or server","created_at":"2009-10-25T23:52:56Z","average_rating":3.5}
RESPONSE
      stub_request(:get, "http://cookbooks.opscode.com/api/v1/cookbooks/ntp/versions/1_0_0").
        with(:headers => {'Accept'=>'application/json', 'User-Agent'=>'Chef Knife/0.10.8 (ruby-1.9.3-p125; ohai-0.6.12; x86_64-darwin11.3.0; +http://opscode.com)', 'X-Chef-Version'=>'0.10.8'}).
        to_return(:status => 200, :body => <<RESPONSE, :headers => {'Content-Type' => 'application/json'})
{"average_rating":null,"created_at":"2011-02-16T17:20:48Z","tarball_file_size":2541,"updated_at":"2011-02-16T17:20:48Z","license":"Apache 2.0","version":"1.0.0","file":"http://s3.amazonaws.com/community-files.opscode.com/cookbook_versions/tarballs/555/original/ntp.tgz","cookbook":"http://cookbooks.opscode.com/api/v1/cookbooks/ntp"}
RESPONSE
      stub_request(:get, "http://s3.amazonaws.com/community-files.opscode.com/cookbook_versions/tarballs/555/original/ntp.tgz").
        with(:headers => {'Accept'=>'*/*', 'User-Agent'=>'Chef Knife/0.10.8 (ruby-1.9.3-p125; ohai-0.6.12; x86_64-darwin11.3.0; +http://opscode.com)', 'X-Chef-Version'=>'0.10.8'}).
        to_return(:status => 200, :body => file_fixture('ntp.tgz'), :headers => {})

      stub_request(:get, "http://cookbooks.opscode.com/api/v1/cookbooks/build-essential").
        with(:headers => {'Accept'=>'application/json', 'User-Agent'=>'Chef Knife/0.10.8 (ruby-1.9.3-p125; ohai-0.6.12; x86_64-darwin11.3.0; +http://opscode.com)', 'X-Chef-Version'=>'0.10.8'}).
        to_return(:status => 200, :body => <<RESPONSE, :headers => {'Content-Type' => 'application/json'})
{"average_rating":5.0,"name":"build-essential","created_at":"2009-10-25T23:49:25Z","category":"Programming Languages","updated_at":"2012-03-20T03:38:29Z","latest_version":"http://cookbooks.opscode.com/api/v1/cookbooks/build-essential/versions/1_0_0","maintainer":"opscode","external_url":"github.com/opscode-cookbooks/build-essential","versions":["http://cookbooks.opscode.com/api/v1/cookbooks/build-essential/versions/1_0_0","http://cookbooks.opscode.com/api/v1/cookbooks/build-essential/versions/0_7_0"],"description":"Installs C compiler / build tools"}
RESPONSE
      stub_request(:get, "http://cookbooks.opscode.com/api/v1/cookbooks/build-essential/versions/1_0_0").
        with(:headers => {'Accept'=>'application/json', 'User-Agent'=>'Chef Knife/0.10.8 (ruby-1.9.3-p125; ohai-0.6.12; x86_64-darwin11.3.0; +http://opscode.com)', 'X-Chef-Version'=>'0.10.8'}).
        to_return(:status => 200, :body => <<RESPONSE, :headers => {'Content-Type' => 'application/json'})
{"average_rating":5.0,"created_at":"2011-04-20T02:39:43Z","tarball_file_size":1317,"updated_at":"2011-10-24T15:16:18Z","license":"Apache 2.0","version":"1.0.0","file":"http://s3.amazonaws.com/community-files.opscode.com/cookbook_versions/tarballs/668/original/build-essential.tgz","cookbook":"http://cookbooks.opscode.com/api/v1/cookbooks/build-essential"}
RESPONSE
      stub_request(:get, "http://s3.amazonaws.com/community-files.opscode.com/cookbook_versions/tarballs/668/original/build-essential.tgz").
        with(:headers => {'Accept'=>'*/*', 'User-Agent'=>'Chef Knife/0.10.8 (ruby-1.9.3-p125; ohai-0.6.12; x86_64-darwin11.3.0; +http://opscode.com)', 'X-Chef-Version'=>'0.10.8'}).
        to_return(:status => 200, :body => file_fixture('build-essential.tgz'), :headers => {})

      stub_request(:get, "http://cookbooks.opscode.com/api/v1/cookbooks/runit").
        with(:headers => {'Accept'=>'application/json', 'User-Agent'=>'Chef Knife/0.10.8 (ruby-1.9.3-p125; ohai-0.6.12; x86_64-darwin11.3.0; +http://opscode.com)', 'X-Chef-Version'=>'0.10.8'}).
        to_return(:status => 200, :body => <<RESPONSE, :headers => {'Content-Type' => 'application/json'})
{"updated_at":"2012-03-20T03:28:10Z","category":"Process Management","maintainer":"opscode","latest_version":"http://cookbooks.opscode.com/api/v1/cookbooks/runit/versions/0_15_0","external_url":"github.com/opscode-cookbooks/runit","name":"runit","versions":["http://cookbooks.opscode.com/api/v1/cookbooks/runit/versions/0_15_0","http://cookbooks.opscode.com/api/v1/cookbooks/runit/versions/0_14_2","http://cookbooks.opscode.com/api/v1/cookbooks/runit/versions/0_14_1","http://cookbooks.opscode.com/api/v1/cookbooks/runit/versions/0_14_0","http://cookbooks.opscode.com/api/v1/cookbooks/runit/versions/0_13_0","http://cookbooks.opscode.com/api/v1/cookbooks/runit/versions/0_12_0","http://cookbooks.opscode.com/api/v1/cookbooks/runit/versions/0_11_0","http://cookbooks.opscode.com/api/v1/cookbooks/runit/versions/0_8_0","http://cookbooks.opscode.com/api/v1/cookbooks/runit/versions/0_7_0"],"description":"Installs runit and provides runit_service definition","created_at":"2009-10-25T23:54:45Z","average_rating":4.5}
RESPONSE
      stub_request(:get, "http://cookbooks.opscode.com/api/v1/cookbooks/runit/versions/0_15_0").
        with(:headers => {'Accept'=>'application/json', 'User-Agent'=>'Chef Knife/0.10.8 (ruby-1.9.3-p125; ohai-0.6.12; x86_64-darwin11.3.0; +http://opscode.com)', 'X-Chef-Version'=>'0.10.8'}).
        to_return(:status => 200, :body => <<RESPONSE, :headers => {'Content-Type' => 'application/json'})
{"updated_at":"2012-03-08T04:03:36Z","file":"http://s3.amazonaws.com/community-files.opscode.com/cookbook_versions/tarballs/1425/original/runit.tgz","cookbook":"http://cookbooks.opscode.com/api/v1/cookbooks/runit","tarball_file_size":10437,"license":"Apache 2.0","average_rating":null,"created_at":"2012-03-08T04:03:36Z","version":"0.15.0"}
RESPONSE
      stub_request(:get, "http://s3.amazonaws.com/community-files.opscode.com/cookbook_versions/tarballs/1425/original/runit.tgz").
        with(:headers => {'Accept'=>'*/*', 'User-Agent'=>'Chef Knife/0.10.8 (ruby-1.9.3-p125; ohai-0.6.12; x86_64-darwin11.3.0; +http://opscode.com)', 'X-Chef-Version'=>'0.10.8'}).
        to_return(:status => 200, :body => file_fixture('runit.tgz'), :headers => {})

      stub_request(:get, "http://cookbooks.opscode.com/api/v1/cookbooks/bluepill").
        with(:headers => {'Accept'=>'application/json', 'User-Agent'=>'Chef Knife/0.10.8 (ruby-1.9.3-p125; ohai-0.6.12; x86_64-darwin11.3.0; +http://opscode.com)', 'X-Chef-Version'=>'0.10.8'}).
        to_return(:status => 200, :body => <<RESPONSE, :headers => {'Content-Type' => 'application/json'})
{"updated_at":"2012-03-22T06:08:05Z","category":"Process Management","maintainer":"opscode","latest_version":"http://cookbooks.opscode.com/api/v1/cookbooks/bluepill/versions/1_0_4","external_url":"github.com/opscode-cookbooks/bluepill","name":"bluepill","versions":["http://cookbooks.opscode.com/api/v1/cookbooks/bluepill/versions/1_0_4","http://cookbooks.opscode.com/api/v1/cookbooks/bluepill/versions/1_0_2","http://cookbooks.opscode.com/api/v1/cookbooks/bluepill/versions/1_0_0","http://cookbooks.opscode.com/api/v1/cookbooks/bluepill/versions/0_3_0","http://cookbooks.opscode.com/api/v1/cookbooks/bluepill/versions/0_2_2","http://cookbooks.opscode.com/api/v1/cookbooks/bluepill/versions/0_2_0","http://cookbooks.opscode.com/api/v1/cookbooks/bluepill/versions/0_1_0"],"description":"Installs bluepill gem and configures to manage services, includes bluepill_service LWRP","created_at":"2010-10-18T22:42:39Z","average_rating":5.0}
RESPONSE
      stub_request(:get, "http://cookbooks.opscode.com/api/v1/cookbooks/bluepill/versions/1_0_4").
        with(:headers => {'Accept'=>'application/json', 'User-Agent'=>'Chef Knife/0.10.8 (ruby-1.9.3-p125; ohai-0.6.12; x86_64-darwin11.3.0; +http://opscode.com)', 'X-Chef-Version'=>'0.10.8'}).
        to_return(:status => 200, :body => <<RESPONSE, :headers => {'Content-Type' => 'application/json'})
{"average_rating":null,"created_at":"2012-03-22T06:08:00Z","tarball_file_size":8560,"updated_at":"2012-03-22T06:08:00Z","license":"Apache 2.0","version":"1.0.4","file":"http://s3.amazonaws.com/community-files.opscode.com/cookbook_versions/tarballs/1452/original/bluepill.tgz","cookbook":"http://cookbooks.opscode.com/api/v1/cookbooks/bluepill"}
RESPONSE
      stub_request(:get, "http://s3.amazonaws.com/community-files.opscode.com/cookbook_versions/tarballs/1452/original/bluepill.tgz").
        with(:headers => {'Accept'=>'*/*', 'User-Agent'=>'Chef Knife/0.10.8 (ruby-1.9.3-p125; ohai-0.6.12; x86_64-darwin11.3.0; +http://opscode.com)', 'X-Chef-Version'=>'0.10.8'}).
        to_return(:status => 200, :body => file_fixture('bluepill.tgz'), :headers => {})

      stub_request(:get, "http://cookbooks.opscode.com/api/v1/cookbooks/ohai").
        with(:headers => {'Accept'=>'application/json', 'User-Agent'=>'Chef Knife/0.10.8 (ruby-1.9.3-p125; ohai-0.6.12; x86_64-darwin11.3.0; +http://opscode.com)', 'X-Chef-Version'=>'0.10.8'}).
        to_return(:status => 200, :body => <<RESPONSE, :headers => {'Content-Type' => 'application/json'})
      {"updated_at":"2012-03-20T03:32:16Z","category":"Utilities","maintainer":"opscode","latest_version":"http://cookbooks.opscode.com/api/v1/cookbooks/ohai/versions/1_0_2","external_url":"github.com/opscode-cookbooks/ohai","name":"ohai","versions":["http://cookbooks.opscode.com/api/v1/cookbooks/ohai/versions/1_0_2","http://cookbooks.opscode.com/api/v1/cookbooks/ohai/versions/1_0_0","http://cookbooks.opscode.com/api/v1/cookbooks/ohai/versions/0_9_0"],"description":"Distributes a directory of custom ohai plugins","created_at":"2010-09-19T15:59:54Z","average_rating":null}
RESPONSE
      stub_request(:get, "http://cookbooks.opscode.com/api/v1/cookbooks/ohai/versions/1_0_2").
        with(:headers => {'Accept'=>'application/json', 'User-Agent'=>'Chef Knife/0.10.8 (ruby-1.9.3-p125; ohai-0.6.12; x86_64-darwin11.3.0; +http://opscode.com)', 'X-Chef-Version'=>'0.10.8'}).
        to_return(:status => 200, :body => <<RESPONSE, :headers => {'Content-Type' => 'application/json'})
{"updated_at":"2011-10-28T20:11:01Z","file":"http://s3.amazonaws.com/community-files.opscode.com/cookbook_versions/tarballs/1062/original/ohai.tgz","cookbook":"http://cookbooks.opscode.com/api/v1/cookbooks/ohai","tarball_file_size":2634,"license":"Apache 2.0","average_rating":null,"created_at":"2011-10-28T20:11:01Z","version":"1.0.2"}
RESPONSE
      stub_request(:get, "http://s3.amazonaws.com/community-files.opscode.com/cookbook_versions/tarballs/1062/original/ohai.tgz").
        with(:headers => {'Accept'=>'*/*', 'User-Agent'=>'Chef Knife/0.10.8 (ruby-1.9.3-p125; ohai-0.6.12; x86_64-darwin11.3.0; +http://opscode.com)', 'X-Chef-Version'=>'0.10.8'}).
        to_return(:status => 200, :body => file_fixture('ohai.tgz'), :headers => {})
      
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
