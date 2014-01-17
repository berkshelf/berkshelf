class File
  class << self
    # Returns true or false if the given path contains a Chef Cookbook
    #
    # @param [#to_s] path
    #   path of directory to reflect on
    #
    # @return [Boolean]
    def cookbook?(path)
      File.exists?(File.join(path, "metadata.json")) || File.exists?(File.join(path, "metadata.rb"))
    end
    alias_method :chef_cookbook?, :cookbook?
  end
end
