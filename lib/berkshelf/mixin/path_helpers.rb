module Berkshelf::Mixin
  # @author Jamie Winsor <reset@riotgames.com>
  module PathHelpers
    # Converts a path to a path usable for your current platform
    #
    # @param [String] path
    #
    # @return [String]
    def platform_specific_path(path)
      if RUBY_PLATFORM =~ /mswin|mingw|windows/
        system_drive = ENV['SYSTEMDRIVE'] ? ENV['SYSTEMDRIVE'] : ""
        path         = win_slashify File.join(system_drive, path.split('/')[2..-1])
      end

      path
    end

    # Convert a unixy filepath to a windowsy filepath. Swaps forward slashes for
    # double backslashes
    #
    # @param [String] path
    #   filepath to convert
    #
    # @return [String]
    #   converted filepath
    def win_slashify(path)
      path.gsub(File::SEPARATOR, (File::ALT_SEPARATOR || '\\'))
    end
  end
end
