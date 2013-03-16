module Berkshelf
  module TestGenerators
    def generate_berks_config(path)
      Berkshelf::Config.new(path,
        ssl: {
          verify: false
        }
      ).save
    end

    # Generate a minimal, default, Chef configuration file
    #
    # @param [#to_s] path
    #   path to the configuration to generate
    def generate_chef_config(path)
      contents = <<-TXT
chef_server_url "http://localhost:4000"
validation_key "/etc/chef/validation.pem"
validation_client_name "chef-validator"
client_key "/etc/chef/client.pem"
      TXT
      File.open(path, 'w+') do |f|
        f.write(contents)
      end
    end
  end
end
