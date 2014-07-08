#
# Patch to allow open-uri to follow safe (http to https) and unsafe
# redirections (https to http).
#
# Original gist URL:
# https://gist.github.com/1271420
#
# Relevant issue:
# http://redmine.ruby-lang.org/issues/3719
#
# Source here:
# https://github.com/ruby/ruby/blob/trunk/lib/open-uri.rb
#
module OpenURI
  class <<self
    alias_method :open_uri_original, :open_uri

    def redirectable_safe?(uri1, uri2)
      uri1.scheme.downcase == uri2.scheme.downcase || (uri1.scheme.downcase == "http" && uri2.scheme.downcase == "https")
    end

    def redirectable_all?(uri1, uri2)
      redirectable_safe?(uri1, uri2) || (uri1.scheme.downcase == "https" && uri2.scheme.downcase == "http")
    end
  end

  # Patches the original open_uri method to follow all redirects
  def self.open_uri(name, *rest, &block)
    class << self
      remove_method :redirectable?
      alias_method  :redirectable?, :redirectable_all?
    end

    self.open_uri_original(name, *rest, &block)
  end
end
