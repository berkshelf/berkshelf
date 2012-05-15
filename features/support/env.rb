require 'spork'

Spork.prefork do
  require 'rspec'
  require 'pp'
  require 'aruba/cucumber'
  
  APP_ROOT = File.expand_path('../../', __FILE__)
  
  Dir[File.join(APP_ROOT, "spec/support/**/*.rb")].each {|f| require f}

  After do
    KCD.clean
  end
end

Spork.each_run do
  require 'kcd'
end
