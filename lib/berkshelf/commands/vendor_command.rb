module Berkshelf
  class VendorCommand < CLI
    include BerksfileOptions
    include FilterOptions

    parameter '[PATH]', 'directory to initialize', default: 'berks-cookbooks'

    def execute
      berksfile.vendor(path, options)
    end
  end
end
