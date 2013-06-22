Given /^the environment variable (.+) is nil$/ do |variable|
  set_env(variable, nil)
end

Given /^the environment variable (.+) is "(.+)"$/ do |variable, value|
  set_env(variable, value)
end
