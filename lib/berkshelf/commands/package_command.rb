module Berkshelf
  class PackageCommand < CLI
    include BerksfileOptions
    option ['-i', '--ignore'], :flag, 'apply the chefignore to contents', default: false
    option ['-o', '--output'], 'PATH', 'path to output the package', default: '.'

    parameter '[NAME]', 'cookbook to package'

    def execute
      berksfile.package(name, options)
    end

    def options
      super.merge(
        output: output,
        ignore_chefignore: ignore?,
      )
    end
  end
end
