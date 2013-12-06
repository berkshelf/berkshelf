class Pathname
  # Returns true or false if the path contains a "metadata.json" or a "metadata.rb" file.
  #
  # @return [Boolean]
  def cookbook?
    join("metadata.json").exist? || join("metadata.rb").exist?
  end
  alias_method :chef_cookbook?, :cookbook?

  # Ascend the directory structure from the given path to find  the root of a
  # Cookbook. If no Cookbook is found, nil is returned.
  #
  # @return [Pathname, nil]
  def cookbook_root
    ascend do |potential_root|
      if potential_root.cookbook?
        return potential_root
      end
    end
  end
  alias_method :chef_cookbook_root, :cookbook_root
end
