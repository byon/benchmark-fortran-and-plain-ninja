
Given(/^any valid configuration$/) do
  create_valid_configuration
end

When(/^files are generated$/) do
  generate
  build
  execute
end

Then(/^there is a file "([^"]*)"$/) do |file|
  assert File.exists? file
end
