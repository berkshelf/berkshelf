# Fix for Facter < 1.7.0 changing LANG to C
# https://github.com/puppetlabs/facter/commit/f77584f4
begin
  old_lang = ENV['LANG']
  require 'ridley'
ensure
  ENV['LANG'] = old_lang
end