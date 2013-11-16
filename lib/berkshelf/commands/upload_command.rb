module Berkshelf
  class Commands::UploadCommand < CLI
    include BerksfileOptions
    include FilterOptions
    include SSLOptions

    parameter '[COOKBOOKS] ...', 'cookbooks to upload'

    option ['-z', '--[no-]freeze'],   :flag, 'freeze uploaded cookbook', default: true
    option ['-f', '--force'],         :flag, 'force upload even if one exists', default: false
    option ['-x', '--[no-]validate'], :flag, 'validate Ruby file syntax before uploading', default: true
    option ['-h', '--halt-frozen'],   :flag, 'halt uploading if a frozen version exists', default: false

    def execute
      berksfile.upload(options)
    end

    def options
      super.merge(
        cookbooks: cookbooks_list,
        freeze: freeze?,
        force: force?,
        validate: validate?,
      )
    end
  end
end
