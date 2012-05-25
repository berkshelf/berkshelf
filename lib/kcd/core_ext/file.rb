class File
  class << self
    # Returns true or false if the given path is a Chef Cookbook
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
