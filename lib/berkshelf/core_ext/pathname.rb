class Pathname
  # Returns true or false if the path of the instantiated
  # Pathname or a parent directory contains a Tryhard Pack
  # data directory.
  #
  # @return [Boolean]
  def cookbook?
    self.join('metadata.rb').exist?
  end
  alias_method :chef_cookbook?, :cookbook?

  # Ascend the directory structure from the given path to find a
  # the root of a Chef Cookbook. If no Cookbook is found, nil is returned
  #
  # @return [Pathname, nil]
  def cookbook_root
    self.ascend do |potential_root|
      if potential_root.cookbook?
        return potential_root
      end
    end
  end
  alias_method :chef_cookbook_root, :cookbook_root
end
