source 'https://rubygems.org'

gemspec

group :guard do
  gem 'coolline',      '~> 0.4.2'
  gem 'guard',         '~> 1.8'
  gem 'guard-cucumber'
  gem 'guard-rspec'
  gem 'guard-spork'

  require 'rbconfig'

  if RbConfig::CONFIG['target_os'] =~ /darwin/i
    gem 'growl', require: false
    gem 'rb-fsevent', require: false

    if `uname`.strip == 'Darwin' && `sw_vers -productVersion`.strip >= '10.8'
      gem 'terminal-notifier-guard', '~> 1.5.3', require: false
    end rescue Errno::ENOENT

  elsif RbConfig::CONFIG['target_os'] =~ /linux/i
    gem 'libnotify',  '~> 0.8.0', require: false
    gem 'rb-inotify', require: false

  elsif RbConfig::CONFIG['target_os'] =~ /mswin|mingw/i
    gem 'rb-notifu', '>= 0.0.4', require: false
    gem 'wdm', require: false
    gem 'win32console', require: false
  end
end

group :test do
  gem "berkshelf-api", git: "https://github.com/berkshelf/berkshelf-api.git"
end
