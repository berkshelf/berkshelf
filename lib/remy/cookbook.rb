class Cookbook
  attr_reader :name, :version_constraint

  def initialize name, version_constraint=nil
    @name = name
    @version_constraint = version_constraint
  end

end
