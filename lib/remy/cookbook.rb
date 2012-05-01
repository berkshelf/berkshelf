class Cookbook
  attr_reader :name, :version_constraint

  def initialize name, version_constraint=nil
    @name = name
    @version_constraint = version_constraint
  end

  def download version
    Chef::Knife::CookbookSiteDownload.new([name, '--file', File.join('/tmp', "#{name}-#{version}.tar.gz").run
  end

end
