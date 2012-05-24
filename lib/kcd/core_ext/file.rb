class File
  class << self
    # Returns true or false if the given path or one of it's
    # parent directories contains a Tryhard Pack data directory.
    #
    # @param [#to_s] path
    #   path of directory to reflect on
    #
    # @return [Boolean]
    def chef_cookbook?(path)
      File.exists?(File.join(path, "metadata.rb"))
    end
  end
end
