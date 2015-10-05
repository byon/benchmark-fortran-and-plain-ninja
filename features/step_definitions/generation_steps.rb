
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

Then(/^file "([^"]*)" defines program "([^"]*)"$/) do |path, program|
  text = File.open(path).read
  assert_match(/program #{program}/, text, 'program start is not defined')
  assert_match(/end program/, text, 'program end is not defined')
end
