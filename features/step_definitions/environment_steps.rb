Given /^the environment variable (.+) is nil$/ do |variable|
  set_environment_variable(variable, nil)
end

Given /^the environment variable (.+) is "(.+)"$/ do |variable, value|
  set_environment_variable(variable, value)
end
