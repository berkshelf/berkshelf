log_level                :info
log_location             STDOUT
node_name                "berkshelf"
client_key               File.expand_path("spec/config/berkshelf.pem")
validation_client_name   "validator"
validation_key           File.expand_path("spec/config/validator.pem")
chef_server_url          "http://localhost:26310"
cache_type               'BasicFile'
cache_options( :path => "#{ENV['HOME']}/.chef/checksums" )
cookbook_path            []
