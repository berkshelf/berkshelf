Given /^I have the Cookbookfile:$/ do |string|
  File.open('Cookbookfile', 'w') do |f|
    f.puts string
  end
  pp Dir.pwd
  pp '#####'
  pp File.read('Cookbookfile')
  pp '#####'
end

Then /^I trace$/ do
  pp Dir.pwd
end
